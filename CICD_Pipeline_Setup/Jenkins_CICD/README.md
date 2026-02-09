#Jenkins

Jenkins — это открытый (open-source) сервер для непрерывной интеграции и непрерывного развертывания (CI/CD).
Мы уже проделали работу по развёртки двух VM через Terraform:

JenkinsServer – 192.168.0.85 (Мастер)

JenkinsAgent – 192.168.0.83 (Worker Node, на ней будет сборка)

Так же проделали работу по первоначальной настройке через Ansible:

JenkinsServer – 192.168.0.85. Установили JDK21, развернули Jenkins server.

JenkinsAgent – 192.168.0.83. Установили JDK21, установили Helm (мы будем брать Charts из нашего репозитория GitHub), Docker (для сборки нашего приложения и пуша в docker hub) и Kubectl (для развёртки нашего приложения в кластере).



1. Начнём со входа на наш Jenkins server. В адресной строке браузера вводим http://192.168.0.85:8080
Получаем информационное сообщение о разблокировке Jenkins. На физическом хосте вводим команду для получения пароля администратора:
- cat /var/lib/jenkins/secrets/initialAdminPassword
Вводим пароль и выбираем уже готовый набор плагинов «Install suggested plugins», потом добавим необходимые. 
Создаём нашего Admin user.
После установки наш Jenkins готов к работе!

2. Установим необходимые нам плагины.
Переходим в Настройки – Plugins – Available Plugins
Нам нужны:
- Docker Pipeline – Для сборки pipeline 
- Docker Commons - Обеспечивает общую функциональность для различных плагинов, связанных с Docker.
- Docker API - Этот плагин предоставляет API docker-java для других плагинов.
- SSH Agent – Он нам потребуется для подключения нашего Jenkins Agent.

Жмём Install и ставим галочку «Перезагрузить Jenkins после установки плагинов»

3. Подключаем Worker Node к нашему мастеру.
Подключение Node будет осуществляться через SSH. Чтобы не нагружать наш Master agent, подключим worker node которая будет осуществлять сборку.
Это нужно для распределения нагрузки, изолирование среды и использовать разных инструментов/ОС

3.1 Генерируем pubkey and private key на Jenkins Master:

- ssh-keygen -t rsa -b 4096
- Передаём значения нашего pubkey в файл  ~/.ssh/authorized_keys на Jenkins Node.
- Делаем рестарт службы SSH на Jenkins Node:
- systemctl restart ssh
- 
Готово, теперь мы можем подключиться по ssh с Jenkins Master к Jenkins Node.
*** Если возникнет проблема, то можно прописать жёстко какой ключ использовать к какому хосту. В нашем случаи, это прописывается на Jenkins Server:

Создаём или отредактируем файл ~/.ssh/config:
- nano ~/.ssh/config
Добавим следующее (значения для текущей задачи):

- Host 192.168.0.83
    - HostName 192.168.0.83
    - User sysadmin
    - IdentityFile ~/.ssh/rsa
    - IdentitiesOnly yes

3.2 Переходим в веб-интерфейс Jenkins и добавляем Node.

Настройки – Nodes – New Node.
Вписываем название узла JenkinsAgent и выбираем тип «Постоянный агент».

Заполним необходимую информацию:

- Имя: JenkinsAgent
- Описание: JenkinsAgent on Linux.
- Количество процессов-исполнителей: 2
- Удалённая корневая директория: /home/sysadmin/jenkins
- Метки: linux, linux_ubuntu, slave
- Использование: Загружать этот узел настолько, насколько возможно
- Способ запуска: Launch Agent via SSH
- Host: 192.168.0.83

__________________________________________________________
Credentials (тут будет передоваться наш private key). Жмём Add и выбираем Jenkins (Jenkins Credential Provider).
- Domain: Global credentials (unrestricted)
- Kind: SSH Username with private key
- Scope: Global
- ID: ssh-key-0-83
- Description: ssh-key to 192.168.0.83
- Username: sysadmin
- Private Key: Enter directly и жмём Add. Сюда мы вводим private key Jenkins Server
- Жмём Add
- Credentials: sysadmin (ssh-key to 192.168.0.83)
- Host Key Verification Strategy: Manually trusted key verification Strategy
- Жмём Сохранить
- 
При положительном исходе, мы должны увидеть подключенную Node (Настройки – Nodes). Там мы увидим наш JenkinsAgent и мастер.

4. Подключим нашу Jenkins Node к Kubernetes cluster. Для дальнейшей развёртки нашего pipeline в кластер.
Скопирую конфиг с нашей Master Node (192.168.0.88):
- sudo cat /etc/kubernetes/admin.conf

Переходим на наш JenkinsAgent (192.168.0.83) и создаём директорию:
- mkdir -p ~/.kube
Копируем в созданный нами файл конфиг с мастер ноды:
- nano ~/.kube/config
и выдаём права:
- sudo chown $(id -u):$(id -g) ~/.kube/config

Запускаем на нашем JenkinsAgent команду:
- kubectl get nodes

Мы должны получить список Node в нашем кластере. 

5. Мы закончили подготовительные действия, теперь мы можем приступить к написанию Pipeline. Какую задачу он будет решать:
- Инженер изменяет наше приложение (index.php) и делает push в наш Git Repository. 
- GitHub делает Webhook, Jenkins серверу, инициируя запуск pipeline.
- Идёт скачивание нашего репозитория на JenkinsAgent и он начинает сборку нового dockerfile.
- Из Dockerfile создаётся Docker Image и пушится в DockerHub.
- Далее включается Helm и на основе нашего Chart приложение разворачивается в нашем k8s cluster.
- Идёт замена подов с предыдущей версией приложения на актуальную

5.1 Очень важно, что бы наш репозиторий с приложением был стандартизирован.

Все файлы были написаны в предыдущих модулях
Pipeline будет разворачиваться из Jenkinsfile в нашем репозитории, будем придерживаться принципа IaC.

Pipeline будет разбит на 5 шагов:
1. Проверка нашего окружения для работы pipeline.
2. Сборка Docker Image на нашем slave
3. Пуш созданного образа в DockerHub
4. Деплой нашего приложения в Kubernetes
5. Проверка деплоя

5.2 Webhook 
Настроим webhook. Нам надо, что бы любое изменение в нашем репозитории запускало сборку приложения.
Наш инженер делает изменение в файле index.php. GitHub webhook отправляет запрос Jenkins серверу. При получении этого запроса Jenkins инициирует запуск Pipeline.
- На сайте github заходим в наш рабочий репозиторий – Settings – Webhooks – Add Webhooks
- В поле Payload URL * прописываем наш JenkinsServer. У него должен быть внешний доступ в интернет, для подключения к GitHub.
- Payload URL *: http://мой_ip:11111/github-webhook/
- Content type *: application/json

В том же окне можно проверить статус подключения. Если запрос вернул код 200, то всё отлично. Связь есть.

6. Credential.
   
Нам нужны дополнительные credential для сборки нашего Pipeline. 
Доступ на наш docker hub репозиторий и конфигурацию Kubernetes cluster.

6.1 Credentials kubeconfig

Заходим на веб-интерфейс Jenkins и переходим:
- Settings -> Credentials -> System -> Global credentials (unrestricted) ->  -> Add Credentials.
- Kind: Secret file
- Scope: Global
- File: загружаем наш config (на k8sMaster в папке ~/.kube/)
- ID: config (kubeconfig-credentials)
- Description: config (kubeconfig-credentials)
- 
6.2 Credential docker hub
- Заходим на веб-интерфейс Jenkins и переходим:
- Settings -> Credentials -> System -> Global credentials (unrestricted) ->  -> Add Credentials.
- Kind: Username with password
- Username: myname
- Password: mypassword
- ID: docker-hub-credentials
- Description: docker-hub-credentials

8. Создание Pipeline
   
В веб-интерфейсе Jenkins нажимаем Новый Item
Вводим название AppPHP и выбираем Pipeline. Жмём Ок.
- Описание: MyJenkins pipeline
- Ставим галочку на Удалять устаревшие сборки -> Сколько последних сборок хранить -> 5 штук
- Triggers -> GitHub hook trigger for GITScm polling
- Definition -> Pipeline script from SCM
- SCM: Git
- Repository URL: https://github.com/barambuxxa/DevOps
- Credentials жмём Add и добавляем private key для подключения репозитория
__________________________________________________________
- Domain: Global Credentials (unrestricted)
- Kind: SSH Username with private key (тут будем добавлять логин к нашему GitHub и private key для подключения)
- Scope: Global
- ID: key_github_ssh
- Description: key_github_ssh
- Username: barambuxxa
- Private Key: Enter directly
- Вводим private ssh key нашего JenkinsServer. 
- Жмём Add
__________________________________________________________
- Добавляем наш credential barambuxxa (key_github_ssh)
- Branch Specifier (blank for 'any'): main
- Script Path: CICD_Pipeline_Setup/Jenkins_CICD/Jenkinsfile
- Жмём Save
- Теперь добавим на GitHub public ssh key нашего JenkinsServer:
- Settings -> SSH and GPG keys -> New SSH key
- Title: My_Token_for_jenkins
- Key type: Autentication Key
- 
Вводим ключ и жмём Add. Ключ должен появиться в списках.

8. Запускаем наш Pipeline в Jenkins. У нас должно развернуть 10 подов с нашим приложением. 
После изменения в репозитории, Jenkins с помощью webhook будет запускать pipeline.

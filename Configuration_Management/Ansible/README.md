#Ansible

У нас уже имеется настроенный гипервизор Proxmox и готовый проект в Terraform, который разворачивает нужное нам количество VM с первоначальной настройкой.
Наши цели:
- Произвести первичную настройку Ansible сервера, для дальнейшей настройки серверов из .yml файлов. Используя метод IaC.
- Настройка серверов под нужные задачи.
- Развертка и настройка Kubernetes кластера.

1. Первичная настройка Ansible сервера.

Один из самых распространённых способ подключения к хостам является SSH. 
- Сгенерируем private и public key, для подключения и передадим его на каждый хост. Можно заново пересоздать VM (кроме Ansible сервер) через Terraform с уже переданным public key. 
*При развёртке VM через Terraform, я передовал public key своего Ansible сервера на VM заранее.
 - Устанавливаем сам Ansible:
sudo apt-get install ansible-core
- В файле ansible.cfg прописываем, где искать адреса хостов и автоматически принимаем ssh fingerprint.
- Создаём hosts.txt файл с нашими хостами. Объединяем в группы и передаём значения.
- Проверяем доступность командой 
sysadmin@MyAnsibleServer:~/ansible_project$ ansible all -m ping
Если получаем PONG, то связь есть.

2. Приступаем к написанию наших плейбуков.
- Сделаем базовую настройку всех VM. Через Ansible Role, так как часто будет необходимость изменений. Чтобы постоянно не переписывать playbook, мы будем менять default values.
Сам playbook называется base_setup.yml, запускается он на всех хостах. Настройки Ansible Role находятся в roles/base_setup
Его основные функции:
- Установка списка пакетов
- Выставление нужной timezone
- Открытие нужных портов
- Добавление ещё одного pubkey на хосты. Можно прописать нужное количество pubkey

2.1 Deploy.

В корне находится файл deploy.yml. В него импортированы ansible playbooks под каждые задачи. Запуск deploy.yml, запускает настройку.
Вводим команду запуска:
ansible-playbook deploy.yml 

У нас следующие задачи:
- Подготовить 3 хоста для сборки Kubernetes кластера.
- Развернуть Jenkins сервер.
- Развернуть Jenkins Agent Node. На нём нам тоже потребуется docker, helm, kubeadm. Kubelet и kubctl. В дальнейшем на нём будет настроен полноценный CI/CD в Kubernetes cluster.
- Развернуть Kubernetes cluster (1 master and 2 worker)
- Настроить между нодами сеть (Calico plugin). Осуществляться это будет через VXLAN. Это протокол туннелирования, который создаёт виртуальную Layer 2 сеть поверх Layer 3 инфраструктуры, позволяя подам в разных нодах Kubernetes общаться как будто они в одной локальной сети.
- Настроить Docker and containderd. Через них будут разворачиваться наши будущее pods.
- Настроить MetalLB. Это балансировщик нагрузки для Kubernetes, который распределяет внешние IP-адреса между сервисами типа LoadBalancer в bare-metal окружениях.
- Установить Helm.
- Конфигурация Kubelet.

Что входит в наш deploy.yml:

- import_playbook: base_setup.yml: 
Установка списка пакетов, выставление нужной timezone, открытие нужных портов и добавление ещё одного pubkey на хосты (В данном случаи это мой pubkey хоста на Windows). Все хосты.


- import_playbook: prepare_system.yml:
Загружаем модули в ядро. Модуль для overlay-файловых систем (требуется для container runtimes) и br_netfilter  (Модуль для фильтрации сетевого трафика на bridge-интерфейсах). 
- import_playbook: install_docker.yml:
Устанавливаем Docker, добавляем пользователя в группу Docker
- import_playbook: config_containerd.yml:
Конфигурируем containerd
- import_playbook: new_install_k8s.yml
Устанавливаем из бинарников kubeadm, kubelet, kubectl. Меняем репозиторий, откуда будут скачиваться images для подов. Я выбрал Китайский.
- import_playbook: config_kubelet.yml
При установки kubelet через бинарный файл, требуется его сконфигурировать. Создаём основной systemd unit файл для kubelet. Запускаем его как daemon.
- import_playbook: init_k8s.yml
Инициализируем cluster. Формируем токен для подключения worker node и создаём скрипт для присоединения join-command.sh.
- import_playbook: install_helm_k8s_master.yml
Устанавливаем Helm. Он нам в дальнейшем потребуется для написания инфраструктуры кластера.
- import_playbook: install_calico.yml
Устанавливаем сетевой плагин, чтобы объединить наши ноды и поды. 
- import_playbook: join_nodes.yml
Копируем ранее созданный скрипт с master node на worker node и запускаем его. Кластер собран и готов к работе.
- import_playbook: install_metalLB.yml
Устанавливаем MetalLB
- import_playbook: install_jenkins.yml
Установка Jenkins сервера
- import_playbook: prepare_slave_jenkins_helm.yml
Установка Helm на Jenkins Agent Node

В результате у нас будет настроен Kubernetes cluster (1 masterNode and 2 workerNode), Jenkins сервер и Jenkins Agent Node не соединённые вместе.

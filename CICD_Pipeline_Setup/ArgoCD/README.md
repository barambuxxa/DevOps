#ArgoCD

ArgoCD. Что за зверь и для чего он нужен? Основная его задача "Слушать" репозиторий. Он наблюдает либо за репозиторием или за папкой в репозитории.
По аналогии с Jenkins мы делаем изменения в gitHub, допустим меняем в манифесте image или количество реплик. ArgoCD видит это и делает изменения в нашем основном кластере. Так что он может видеть изменения в helme и тоже перезапускать deploymentы.
Главное различие между Jenkins и ArgoCD, в том что ArgoCD разворачивается только в Kubernetes и его основной задачей является деплой именно в Kubernetes cluster.
ArgoCD не включает в себя этапы сборки и тестов. 

Лучше всего использовать оба метода.
Jenkins → сборка образа, тесты, push в registry, обновление Helm chart в Git.
ArgoCD → автоматический деплой из обновлённого Helm chart в Kubernetes.

У нас уже развёрнуты 3 VM под кластер с помощью Terraform и сконфигурирован рабочий Kubernetes cluster с помощью Ansible.

- k8smaster – 192.168.0.88 (Master Node)
- worknode1 – 192.168.0.87 (Worker Node 1)
- worknode2 – 192.168.0.86 (Worker Node 2)

1. Установка AgroCD в наш кластер
- Создадим namespace для ArgoCD:

- kubectl create namespace argocd

- Устанавливаем ArgoCD с помощью официального манифеста.
Разворачиваем pods в ранее созданное пространство из манифеста:
- kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Проверим наши pods командной 
- kubectl get pods -A

У нас уже настроен LoadBalancer и MetalLB для выдачи externalIP

При развёртки через манифест наш argocd-server поднимается в ClusterIP. Для того, чтобы получить external IP необходимо поменять тип на LoadBalancer:
- kubectl edit svc argocd-server -n argocd

ищем spec:
	type: ClusterIP 
и меняем на LoadBalancer

После замены, мы получаем доступ к веб-интерфейсу ArgoCD по выданному external IP.
Логин для входа admin, пароль можно узнать следующей командой:
- kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

Логинемся в веб-интерфейс и приступим к настройке:

2. Подключение репозитория.

Нам нужно подключить наш github репозиторий в ArgoCD, чтобы он мог его слушать.

Подключение будет осуществляться через SSH.

Для этого надо сформировать public and private ssh key.

Public key будет добавлен в github – SSH and GPG keys.

Private key будет добавлен в ArgoCD. 

Формируем наш ключ на master node:
- ssh-keygen -t rsa -b 4096
- 
Теперь добавим на GitHub public ssh key нашего k8smaster:

Settings -> SSH and GPG keys -> New SSH key
- Title: My_Token_for_argocd
- Key type: Autentication Key

Вводим ключ и жмём Add. Ключ должен появиться в списках.

Теперь подключим наш репозиторий, заходиv в ArgoCD -> Settings -> Repositories -> + Connect Repo

- Choose your connection method: VIA SSH
- Name (mandatory for Helm): argocd_repo
- Project: default
- Repository URL: git@github.com:barambuxxa/DevOps.git
  
Нажимаем Connect, наш ArgoCD должен подключиться к нашему репозиторию

3. Создание Application
Создадим Application. Нам нужно, чтобы наше приложение собиралось из github репозитория и синхронизировалось с ним. Инженер делает push в проект и argocd его разворачивает в нашем кластере.

- Выбираем Applications -> + New App
- Application Name: app1
- Project name: default
- Sync Policy: Automatic
- Source/RepositoryURL: git@github.com:barambuxxa/argocd_CICD.git (он даст выбрать из подключенных репозиториев)
- Revision: HEAD
- Path: HelmCharts/MyChart1 (нахождение нашего Chart)
- DESTINATION/Cluster URL: https://kubernetes.default.svc (в текущей кластер где развёрнут ArgoCD)
- Namespace: default
- 
Далее жмём CREATE

4 Проверка

Проверим наш CD Pipeline. Мы запустили развёртку Deployment и Service, который создал нам 6 подов с веб-приложением.

Сейчас мы изменим количество replicaCount с 6 до 10.

1. Мы скачаем наш проект с github
2. Отредактируем файл CICD_Pipeline_Setup/ArgoCD/HelmCharts/MyChart1/values.yaml
3. Изменим значение replicaCount с 6 до 10 и сделаем Push.
4. Ожидание, когда ArgoCD увидит изменение в репозитории.


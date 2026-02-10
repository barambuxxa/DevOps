#Manifest for Kubernetes

Сделаем развёртку приложения в нашем k8s cluster. Вручную.

Мы уже собрали наш docker image и загрузили его в наш репозиторий на dockerHub. У нас уже имеется собранный K8s cluster из 1 MasterNode (192.168.0.88) и 2 WorkerNode (192.168.0.86 и 192.168.0.87). Теперь мы можем развернуть наше приложение в k8s cluster.
Начнём с ручной настройки, через манифесты (не используя Helm). Для этого нам потребуется создать
- deployment manifest (deployment-gurenich-v1.yml)
- service manifest (service-gurenich.yml)

1. Deployment manifest.

Создаём 6 реплик в namespace my-web-deployment. Выбираем из какого образа будем разворачивать, на каком порту и с какими параметрами cpu и memory.

Запускаем его командой:
- kubectl apply -f deployment-gurenich-v1.yml

Проверяем поднятые поды:
- kubectl get pods -o wide
2. Service manifest

Переходим к созданию сервисов. Они нужны для более удобного подключения ко всем подам и деплоям.
Поднимаем сервис в режиме LoadBalancer

Запускаем его командой:
- kubectl apply -f service-gurenich.yml

Проверяем наш сервис:
- kubectl get services -o wide
3. Ранее мы разворачивали MetalLB (через Ansible playbook) и уже имеем пул external_ip (192.168.0.72-192.168.0.75). Но данный yaml файл всё равно добавлен в каталог, в нашем случаи его можно не использовать.

Проверяем, получил ли наш сервис External IP:
- kubectl get services -o wide

Теперь мы можем обратиться по выделенному сервису ip адресу и нам вернёт страничку любой из 6 поднятых подов, в моём случаи по адресу: http://192.168.0.75/

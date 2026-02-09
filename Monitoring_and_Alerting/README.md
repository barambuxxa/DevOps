#Monitoring
Нам надо понимать, что происходит снаружи кластера, внутри кластера и что происходит с нашим приложением.

Для этого мы развернём в нашем Kubernetes кластере kube-prometheus-stack, через Helm.
В него входят следующие инструменты:

- Prometheus. Нужен для сбора метрик.
- Grafana. Дашборды и визуализация полученных метрик.
- Alertmanager. Обработка оповещений.
- Node-exporter. Агенты которые будут собирать метрики с наших нод. 
1. Установка prometheus-stack
 
Так как мы будем устанавливать через helm, то добавляем наш Prometheus Stack репозиторий.

- helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
- helm repo update
  
После этого создаём отдельный Namespaces для Prometheus Stack:

- kubectl create namespace monitoring
 
Начинаем установку Prometheus Stack
Добавляем флаги:

- --namespace monitoring //Устанавливаем в определённый namespace
- --set grafana.adminPassword=admin123 //Устанавливаем пароль для входа в Grafana
- --set alertmanager.enabled=true //Включаем Alertmanager
- --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

А вот тут мы отключаем на выбор ServiceMonitor. С флагом false 
•	Prometheus будет мониторить ВСЕ ServiceMonitor'ы в кластере
•	Автоматическое обнаружение новых приложений с метриками
•	Гибкая настройка мониторинга для кастомных приложений

- helm install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword=admin123 \
  --set alertmanager.enabled=true \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
При успешной развёртке мы увидим новые Service Prometheus

2. Архитектура

В нашем случаи, мы будем иметь доступ только к веб-интерфейсу Grafana.
Prometheus, Grafana, Node-exporter и Alertmanager будут общаться внутри сети Kubernetes.

Поменяем тип сервиса prometheus-stack-grafana на LoadBalancer через редактирование.

- kubectl edit svc prometheus-stack-grafana -n monitoring

По полученному IP, зайдём на веб-интерфейс Grafana с помощью логина (admin) и пароля (admin123).

За основу Dashbords возьмём следующую структуру:
1. CLUSTER OVERVIEW (общий дашборд)
2. NODES MONITORING (метрики нод)
3. PODS & WORKLOADS (поды и приложения)
4. APPLICATIONS (ваше приложение)

3. Dashboards

Dashboard создаётся следующим образом:

Dashboards -> New -> New dashboard -> + Add Visualization -> Select data source (Prometheus).

3.1 CLUSTER OVERVIEW (общий дашборд)
Назовём наш Dashboard «Kubernetes Cluster Overview». Тут мы будем отслеживать общую информацию по количеству nodes and pods в нашем кластере.
Выведем следующие метрики:
- Количество Node в нашем кластере (Nodes Count)
- Количество Node в нашем кластере, в статусе Ready (Ready Nodes Count)
- Количество Pods в нашем кластере (Pods Count)
- Соотношение pods по статусам (Pod Status)

Nodes Count

Создаём метрику с визуализацией типа Stat (простой счётчик). В ней будет запрос:
- count(kube_node_info)

Ready Nodes Count

Создаём метрику с визуализацией типа Stat (простой счётчик). В ней будет запрос: 
- sum(kube_node_status_condition{condition="Ready"})

Pods Count

Создаём метрику с визуализацией типа Stat (простой счётчик). В ней будет запрос:
- count(kube_pod_info)

Pod Status

Создаём метрику с визуализацией типа Pie chart. Соотношение статусов pods (Running, Failed, Pending, Succeeded, Unknown) В ней будет запрос:
- sum by (phase) (kube_pod_status_phase)

3.2 NODES MONITORING (метрики нод)

В этом Dashboard будем отслеживать физическое состояние Node.
Выведем следующие метрики:
- % нагрузки CPU на ноде. (CPU Usage %)
- Средняя нагрузка CPU на ноде. (CPU Load Average)
- Использованное количество оперативной памяти на ноде (Memory Used (GB))
- % использованной памяти на ноде (Memory Usage %)
- Свободное дисковое пространство на ноде (Free Disk Space GB)
- Процент использованного пространства диска (Disk Usage %)
- Отправленный сетевой трафик с каждой ноды (Network Traffic Transmit MB/s)
- Полученный сетевой трафик с каждой ноды (Network Traffic Receive MB/s

CPU Usage %

Создаём метрику с визуализацией типа bar gauge (столбчатый индикатор). В ней будет запрос:
- 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
Формируется по каждой ноде

CPU Load Average

Создаём метрику с визуализацией типа Time series (временной график). В ней будет запрос:
- node_load1
  
Так же поставим легенду в этом графике, по instance (это можно сделать в панели ниже, в Options)

Memory Used (GB)

Создаём метрику с визуализацией типа bar gauge (столбчатый индикатор). В ней будет запрос:
- (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / 1024 / 1024 / 1024

Так же поставим легенду в этом графике, по instance
Добавим визуальное изменение, если значение превышает 1.8. В нашем случаи это превышение 1.8ГБ
Это делается в панели Виртуализации, во вкладке Thresholds

Disk Usage %

Создаём метрику с визуализацией типа Stat (простой счётчик). В ней будет запрос:
- (1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})) * 100
Так же поставим легенду в этом графике, по instance.

Добавим цветовую гамму:
от 0 до 49 – зелёный цвет
от 50 до 69 – жёлтый
От 70 красный

Network Traffic Transmit MB/s

Создаём метрику с визуализацией типа Time series (временной график). В ней будет запрос:
- rate(node_network_transmit_bytes_total{device=~"eth.*|ens.*|eno.*|bond.*"}[5m]) * 8 / 1024 / 1024
  
Так же поставим легенду в этом графике, по instance.

Network Traffic Receive MB/s

Создаём метрику с визуализацией типа Time series (временной график). В ней будет запрос:
- rate(node_network_receive_bytes_total{device=~"eth.*|ens.*|eno.*|bond.*"}[5m]) * 8 / 1024 / 1024
  
Так же поставим легенду в этом графике, по instance.

3.3 PODS & WORKLOADS (поды и приложения)

В этом Dashboard будет отслеживаться состояние pods и рабочая нагрузка на pods.
- Количество pods в каждом Namespace (Pods by Namespace)
- Использование памяти каждым namespace (Memory Usage by Namespace MB)
- Счётчик рестартов подов в каждом namespace (Restart pods count)
- Статусы, в которых находятся поды (Pods by Status)

Pods by Namespace

Создаём метрику с визуализацией типа Stat (простой счётчик). В ней будет запрос:
- count by (namespace) (kube_pod_info)

Memory Usage by Namespace MB

Создаём метрику с визуализацией типа Time series (временной график). В ней будет запрос:
- sum by (namespace) (container_memory_working_set_bytes{container!="", container!="POD"}) / 1024^2

Restart pods count

Создаём метрику с визуализацией типа Gauge (датчик). В ней будет запрос:
- sum by (namespace) (increase(kube_pod_container_status_restarts_total[24h]))

Изменим Thresholds, более 5 перезагрузок для нас будет критично и будет подсвечено красным.

Pods by Status

Создаём метрику с визуализацией типа Stat (простой счётчик). В ней будет запрос:
- sum by (phase) (kube_pod_status_phase)

3.4 APPLICATIONS (Приложение)

В этом Dashboard будет отслеживаться состояние нашего приложения

Выведем следующие метрики:
- Сколько задействовано CPU для конкретного пода с приложением (CPU Usage)
- Сколько оперативной памяти задействовано пода с приложением (Memory Used MB)

CPU Usage

Создаём метрику с визуализацией типа Time series (временной график). В ней будет запрос:
- sum(rate(container_cpu_usage_seconds_total{pod=~"app1-deployment.*"}[5m])) by (pod)
  
Memory Used MB

Создаём метрику с визуализацией типа Time series (временной график). В ней будет запрос:
- sum(container_memory_working_set_bytes{pod=~"app1-deployment.*"}) by (pod) / 1024/1024

Настройка Alertmanager

У нас уже построены Dashboard для определённых метрик. Теперь настроим уведомления в Telegram для отслеживания изменений в нашем кластере. 

4.1 Создание бота в Telegram

Нам потребуется создать бота, добавить его в группу в которую он будет отправлять уведомления и получить id чата.
Для этого нам надо написать боту @BotFather в Telegram и создать бота. Выбираем имя K8salertsbotgurenich и жмём создать. После создания мы получим token_id.

Наш токен ID будет 8226541607:AAHTU69cBQ5hCTpWcSK$$$$$$$$U%%%%%%.

Далее создаём группу в telegram, добавляем туда нашего бота и узнаём chat_id.

Далее в коде данные chat_id и token_id будут скрыты, для безопасности.

4.2 Конфигурация Alertmanager

У нас уже имеется поднятый под alertmangaer, который установился вместе с Prometheus Stack.
Поэтому у него уже есть настройки по умолчанию, которые нам надо изменить, чтобы привязать уведомления в Telegram через бот.

Secret перезаписывает ВСЮ конфигурацию - нельзя изменить только чат ID, нужно обновлять весь файл
После изменения secret нужно рестартовать Alertmanager
Так как был поднят Alertmanager из Prometheus Stack, то Helm Chart автоматически генерирует свой конфиг и перезапишет наш конфиг. Для этого нам надо создать файл с нашим конфигом и обновить Helm values нашим конфигом. Конфиг в репозитории, с названием alertmanager-values.yaml (НУЖНО ЗАМЕНИТЬ ЗНАЧЕНИЯ НА СВОИ chat_id и token_id).

После этого обновляем Helm values и применяем его:

- helm upgrade prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring -f alertmanager-values.yaml --reuse-values

Проверим тестовым запросом:

cat <<EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: alert-test-2
  namespace: monitoring
  labels:
    release: prometheus-stack
spec:
  groups:
  - name: test
    rules:
    - alert: TestAlertToTelegram
      expr: vector(1)
      for: 1m  # измените на положительное значение, например 1m
      labels:
        severity: warning
      annotations:
        summary: "Test Telegram"
        description: "Testing if Telegram works"
EOF

При положительном результате мы должны получить уведомление в Telegram

5. Уведомления в Telegram

Напишем 4 базовых уведомления для нашего кластера:
- Свободное дисковое пространство на ноде
- Статус неподнятой поды
- Информация о нехватке оперативной памяти в кластере

Мы разделим уведомления для конкретных целей.
- Файл 01-infrastructure.yaml будет отвечать за состояние нод. В него будут добавлены уведомления по нехватки памяти и свободное пространство на диске.
- Файл 02-kubernetes.yaml отвечать за состояние под. В него будет добавлено уведомление о неподнятой поде.

5.1 Свободное дисковое пространство на ноде и нехватка памяти.

Создадим yaml файл с именем 01-infrastructure.yaml.

Основная его задача будет в уведомлении, что свободное дисковое пространство на ноде достигло менее 40% и информация о том что памяти использовано больше 50%

- kubectl apply -f 01-infrastructure.yaml

5.2 Уведомление о неподнятой поде.

Данное уведомление будет информировать о том, что пода находится в состояние Pending. 

Для уведомлений о подах будет создан отдельный файл 02-kubernetes.yaml

После этого делаем apply

- kubectl apply -f 02-kubernetes.yaml

Инициируем проверку алерта. Создадим намеренно под с очень большими ресурсами, который не сможет развернуться в нашем кластере. Со значением cpu =1000:
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-pending-pod-$(date +%s)
  namespace: default
spec:
  containers:
  - name: pending-container
    image: busybox
    command: ["sleep", "3600"]
    resources:
      requests:
        memory: "1Ti"  # Заведомо недостижимое значение
        cpu: "1000"
EOF

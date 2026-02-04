#Docker
Наши задачи:
- Написать простое приложение, страничку. Которая будет отдавать простую информацию:
- Текстовое приветствие
- Текстовую информацию о странице
- Информацию о сервере, где запущен контейнер
- Текущую дату
- IP адрес контейнера
- Hostname где запущен контейнер с приложением.
- Добавим health check статус. Он нам потребуется для дальнейшего отслеживания и визуализации метрик нашего приложения через связку Prometheus + Grafana.
- Создать Docke rfile, с нашим приложением.
- Создать Docker image из нашего Docker file
- Создание Docker контейнера из нашего Docker image.
- Пуш Docker image в Docker hub.

1. Код страницы с health метриками находится в файле index.php
2.  Создаём Docker file, в котором пропишем инструкцию для сборки Docker Image.
- Используем определённую версию php
- Включаем mod_rewrite, чтобы наш Prometheus имел доступ к расположению \health.

- Копируем index.php и .htaccess в нужные директории.
3. Из написанного Docker file, мы можем создать Docker Image.
Воспользуемся командой:
- docker build -t php-app-gurenich:v1 .
4. Docker контейнер
- Мы можем посмотреть созданный нами Docker image командой:
docker images
- Мы можем создать контейнер из нашего Docker Image командой:
- docker run -d -it -p 80:80 php-app-gurenich:v1
Запускаем docker контейнер в фоновом режиме и с интерактивным режимом. Так же прокидываем порт 80 контейнера на 80 порт хост машины, где запущен Docker. 

Теперь мы можем посмотреть наше веб-приложение запущенное в Docker контейнере.
Страница должна вывести нам информацию о хосте, где запущен Docker контейнер с приложением.

5. Загрузим наш docker image на docker hub (https://hub.docker.com/). У меня уже есть учётная запись и создан репозиторий https://hub.docker.com/repository/docker/gumidu/php-app-gurenich/general

Логинемся с нашего хоста к docker hub и вводим пароль:
docker login -u gumidu

Протегируем наш image на локальной машине:
- docker tag php-app-gurenich:v1 gumidu/php-app-gurenich:latest
И делаем push:
- docker push gumidu/php-app-gurenich:latest

Готово, наш docker image загружен в репозиторий и мы можем им пользоваться.

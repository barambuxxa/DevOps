#Yandex cloud


Данный раздел будет описывать работу с Yandex Cloud. Как будет идти развёртка инстансов Yandex cloud через Terraform. 

Для начала создадим сервисный аккаунт в YC для Terraform:

- Войдём в консоль управления Yandex Cloud
- Выберем каталог в котором будет работать Terraform
- Переходив во вкладку сервисные аккаунты и мём создать.

выдача токена для Terraform поизводится через CLI, установка на Windows осуществляется через PowerShell командой:
- iex (New-Object System.Net.WebClient).DownloadString('https://storage.yandexcloud.net/yandexcloud-yc/install.ps1')

Далее инициализируем наше облако:
- yc init

Далее нужно:
1. Перейти по ссылке и получить OAuth-токен (это нужно сделать один раз при первой настройке)
2. Вставить этот токен в терминал
3. Выбрать ваше облако из списка
4. Выбрать каталог по умолчанию
5. Выбрать зону доступности

Теперь создадим наш закрытый ключ для подключения ранее созданного сервисного аккаунта к YC:
- yc iam key create --service-account-name <ваш сервисный аккаунт> --output key.json

В итоге мы получим Авторизованный ключ key.json. Который в дальнейшем мы положим в наш каталог Terraform.

теперь настроим наш провайдер для подключения Terraform к YC.

Скачиваем нужную версию с официально репозитория:
https://github.com/yandex-cloud/terraform-provider-yandex/releases

Я использую Windows. Нужно положить все файлы в папку:
- C:\Users\andrey.gurenich\AppData\Roaming\terraform.d\plugins\registry.terraform.io\yandex-cloud\yandex\0.187\windows_amd64

Начальная настройка завершена.

#Proxmox

В качестве гипервизора был выбран Proxmox, так как он является open-source enterprise solutions.
Для развёртки была использована физическая машина со следующими характеристиками:
Процессор: Intel Core i5-14400
Оперативная память 32ГБ DDR4
250ГБ SSD диск

Настройка гипервизора:
1. Скачиваем ISO образ по ссылке https://enterprise.proxmox.com/iso/proxmox-ve_9.0-3.iso (Версии могут меняться, последнюю версию всегда можно посмотреть тут https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso).
2. Создаём установочную флешку со скаченным образом Proxmox VE. Я использовал программу Rufus.
3. Разворачиваем Proxmox VE 9.0 на нашу физическую машину. Устанавливаем сетевые настройки, логин, пароль, SSH сервер.
4. После успешной установки подключаемся к нашему серверу по SSH. Проведём первичную настройку:
- Удалим платные репозитории proxmox enterprise, их можно найти в каталоге /etc/apt/sources.list.d
- Обновим наш сервер, чтобы иметь актуальные пакеты. apt-get update & apt-get upgrade
- Создадим учётную запись, роль и токен для Terraform, чтобы мы могли создавать VM через Terraform (IaC).

- pveum role add TerraformUser -privs "User.Modify Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit Pool.Allocate SDN.Use"                           - Создаём роль ( TerraformUser )
- pveum user add terraform-provider@pve --password qwerty123                                            - Добавляем пользователя (terraform-provider@pve) и присваиваем ему пароль
- pveum aclmod / -user terraform-provider@pve -role TerraformUser                                       - Добавляем роль к созданному пользователю. Pveum aclmod – команда для управления правами доступа.
- pveum user token add terraform-provider@pve mytoken                                                   - Генерируем токен для подключения по API. Чтобы можно было разворачивать VM из main.tf

- Готовый скрипт находится в файле create_user_terraform.sh

- Обязательно снимаем галочку Privilege Separation, чтобы роли не пересекались между собой. Из-за этого, в новых версиях Proxmox могут быть конфликты. Находится она в Datacenter -> Permissions -> API Tokens -> выбираем созданный токен и через Edit Снимаем галочку.

5. Для развёртывания виртуальных машин через Terraform, нам необходим шаблон. Terraform будет создавать виртуальные машины из шаблона и передавать настройки через Cloud-init.
Можно установить чистую ОС, настроить и сделать из неё шаблон. Но можно развернуть уже готовый образ:
- Скачиваем cloud image образ, который уже готов к работе. Что бы не настраивать VM с нуля. Качаем через wget. Складывать всё будет в папку /var/lib/vz/snippets
- mkdir /var/lib/vz/snippets
- wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
- Далее создаём VM через консоль:
- qm create 9000 --name ubuntu-2404-cloudinit-template
- qm set 9000   --virtio0 local-lvm:0,import-from=/var/lib/vz/snippets/noble-server-cloudimg-amd64.img   --scsihw virtio-scsi-pci
Создаём шаблон из созданной VM:
- qm template 9000



6. Подключаем Cloud-init. Инструмент для первоначальной настройки виртуальных машин, при их первом запуске.
В папке /var/lib/vz/snippets сниппетов на локальном сервере proxmox и добавляем простой сниппет, который:
- обновляет пакеты и устанавливает пакет qemu-guest-agent
- ставит автозагрузку службы и запускает службу. 
- создаём пользователя, под которым будем авторизовываться и выдадим ему root права.
- добавляем наш ssh public ключ, для подключения. И разрешаем подключение только по ssh.
- перезапускаем службу ssh.

- Создаём файл qemu-guest-agent.yml, файл можно найти в текущей папке.
- Желательно заменить имя пользователя.
- Обязательно надо вписать свой public key.

Настройка гипервизора Proxmox VE завершена, приступаем к написанию кода Terraform. 

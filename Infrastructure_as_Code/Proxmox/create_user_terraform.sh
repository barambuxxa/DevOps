#!/bin/bash

# Скрипт для настройки пользователя и прав для Terraform в Proxmox VE
# Запускать на ноде Proxmox

# Создание роли с необходимыми привилегиями
echo "1. Создание роли TerraformUser..."
pveum role add TerraformUser -privs "User.Modify Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit Pool.Allocate SDN.Use"

# Создание пользователя
echo "2. Создание пользователя terraform-provider@pve..."
# Внимание! Замените 'qwerty123' на надежный пароль!
pveum user add terraform-provider@pve --password qwerty123

# Назначение прав пользователю
echo "3. Назначение прав пользователю..."
pveum aclmod / -user terraform-provider@pve -role TerraformUser

# Генерация API токена
echo "4. Генерация API токена..."
pveum user token add terraform-provider@pve mytoken

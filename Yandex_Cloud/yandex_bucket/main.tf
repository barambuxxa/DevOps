#Создаём наш bucket

resource "yandex_storage_bucket" "Backup_bucket" {

  #Имя бакета
  bucket = "my-bucket-30gb-for-backup-andrey-gurenich"

  #Размер нашего бакета
  max_size = 32212254720

  #Наш каталог на облаке
  folder_id = "b1gjniml652ji4hn8sgi"

  #Выбираем класс нашего bucket
  default_storage_class = "STANDARD"

  #Запрещаем удаление если в бакете что то хранится, для безопасности
  force_destroy = false

  #Прописываем теги
  tags = {
    Name        = "30GB"
    Environment = "backup"
    CreatedBy   = "terraform"
  }
}

# Вывод информации по нашему bucket
output "bucket_name" {
  description = "Имя созданного бакета"
  value       = yandex_storage_bucket.Backup_bucket
  sensitive   = true
}

output "bucket_domain" {
  description = "Домен в котором создан бакет"
  value       = yandex_storage_bucket.Backup_bucket.bucket_domain_name
}

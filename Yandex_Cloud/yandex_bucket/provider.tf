terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.187"
    }
  }
}

provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id                 = "b1g8odmcmm95osagj70g"
  folder_id                = "b1gjniml652ji4hn8sgi"
  zone                     = "ru-central1-a"
}

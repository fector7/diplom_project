terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.129.0"
    }
  }
  required_version = ">= 1.8.4"
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = file(var.service_account_key_file)
}

locals {
  zones = {
    a = "ru-central1-a"
    b = "ru-central1-b"
  }
  labels = {
    project     = "netology-diplom"
    terraform   = "true"
    environment = "production"
  }
}

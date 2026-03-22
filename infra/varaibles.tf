variable "folder_id" {
  description = "ID каталога в Yandex Cloud"
  type        = string
}

variable "zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}

variable "catalog_name" {
  description = "Наименование каталога"
  type        = string
  default     = "default"
}

variable "image_id" {
  description = "ID образа для загрузочного диска"
  type        = string
  default = "d8fpk9lkplfjrc5s2gg"
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ для доступа к виртуальной машине"
  type        = string
  sensitive   = true
}

variable "vm_user" {
  description = "Имя пользователя виртуальной машины"
  type        = string
  sensitive   = true
}
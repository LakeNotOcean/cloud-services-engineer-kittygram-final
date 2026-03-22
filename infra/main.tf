terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.89.0"
    }
  }


  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "ch3shirskins-terraform-state"
    region = "ru-central1-a"
    key    = "tf-state.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  zone      = var.zone
  folder_id = var.folder_id
}

# Сборка конфигурации cloud-init
locals {
  user_config = templatefile("${path.module}/init-scripts/cloud-init.user.yml", {
    vm_user        = var.vm_user
    ssh_public_key = var.ssh_public_key
  })
  docker_config = file("${path.module}/init-scripts/cloud-init.docker.yml")

  # Собираем дополнительные скрипты для настройки
  scripts_paths = fileset("${path.module}/init-scripts/additional-scripts", "*.sh")

  scripts_write_files_list = [for script_path in local.scripts_paths : {
    path    = "/usr/local/bin/${basename(script_path)}"
    content = file("${path.module}/init-scripts/additional-scripts/${script_path}")
  }]
  scripts_write_files=yamlencode(local.scripts_write_files_list)

  cloud_init = <<-EOF
    ${local.user_config}
    ${local.docker_config}
    write_files:
    ${local.scripts_write_files}
    runcmd:
      - chmod +x /usr/local/bin/*.sh
      - for script in /usr/local/bin/*.sh; do bash $script; done
  EOF
}

# Резервирование IP адреса
resource "yandex_vpc_address" "addr" {
  name                = var.catalog_name
  deletion_protection = "false"
  external_ipv4_address {
    zone_id = var.zone
  }
}

# Создание сети
resource "yandex_vpc_network" "kittygram-network-1" {
  name = "kittygram-network-1"
}


# Создание подсети
resource "yandex_vpc_subnet" "kittygram-subnet-1" {
  name           = "kittygram-subnet-1"
  zone           = var.zone
  network_id     = yandex_vpc_network.kittygram-network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Создание группы безопасности
resource "yandex_vpc_security_group" "kittygram-group" {
  name       = "kittygram-group"
  network_id = yandex_vpc_network.kittygram-network-1.id

  ingress {
    description    = "Allow HTTP"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  ingress {
    description    = "Allow SSH"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  egress {
    description    = "Allow all outgoing"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

# Созданеи диска
resource "yandex_compute_disk" "kittygram-boot-disk-1" {
  name     = "kittygram-boot-disk-1"
  type     = "network-hdd"
  zone     = var.zone
  size     = "20"
  image_id = var.image_id
}

resource "yandex_compute_instance" "kittygram-vm-1" {
  name                      = "kittygram-vm-1"
  platform_id               = "standard-v1"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    disk_id = yandex_compute_disk.kittygram-boot-disk-1.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.kittygram-subnet-1.id
    nat                = true
    nat_ip_address     = yandex_vpc_address.addr.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.kittygram-group.id]
  }

  metadata = {
    enable-oslogin = true
    user-data      = local.cloud_init
  }
}

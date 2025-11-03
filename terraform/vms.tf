data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  zone        = local.zones.a
  platform_id = "standard-v3"
  resources {
    cores         = var.vm_sizes["small"].cores
    memory        = var.vm_sizes["small"].memory
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.vm_sizes["small"].disk
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.public_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion.id]
  }
  metadata = {
    "user-data" = templatefile("${path.module}/cloud-init.tftpl", {
      ssh_key  = var.ssh_public_key
      username = var.vm_user
      hostname = "bastion"
    })
  }
  scheduling_policy {
    preemptible = true
  }
  labels = merge(local.labels, { role = "bastion" })
}

resource "yandex_compute_instance_group" "web" {
  name               = "web-instance-group"
  service_account_id = var.service_account_id
  
  instance_template {
    platform_id = "standard-v3"
    name        = "web-{instance.index}"
    hostname    = "web-{instance.index}"
    resources {
      cores         = var.vm_sizes["small"].cores
      memory        = var.vm_sizes["small"].memory
      core_fraction = 100
    }
    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu.id
        size     = var.vm_sizes["small"].disk
      }
    }
    network_interface {
      network_id         = yandex_vpc_network.main.id
      subnet_ids         = [yandex_vpc_subnet.private_a.id, yandex_vpc_subnet.private_b.id]
      security_group_ids = [yandex_vpc_security_group.web.id]
    }
    metadata = {
      "user-data" = templatefile("${path.module}/cloud-init-web.tftpl", {
        ssh_key  = var.ssh_public_key
        username = var.vm_user
        hostname = "web-{instance.index}"
      })
    }
    scheduling_policy {
      preemptible = true
    }
    labels = merge(local.labels, { role = "webserver" })
  }
  
  scale_policy {
    auto_scale {
      initial_size           = 2
      measurement_duration   = 60
      cpu_utilization_target = 75
      min_zone_size          = 1
      max_size               = 3
    }
  }
  
  allocation_policy {
    zones = [local.zones.a, local.zones.b]
  }
  
  deploy_policy {
    max_unavailable = 1
    max_expansion   = 1
  }
  
  application_load_balancer {
    target_group_name = "web-target-group"
  }
  
  health_check {
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    http_options {
      port = 80
      path = "/"
    }
  }
}

resource "yandex_compute_instance" "zabbix_server" {
  name        = "zabbix-server"
  hostname    = "zabbix-server"
  zone        = local.zones.a
  platform_id = "standard-v3"
  resources {
    cores         = var.vm_sizes["medium"].cores
    memory        = var.vm_sizes["medium"].memory
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.vm_sizes["medium"].disk
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.private_a.id
    security_group_ids = [yandex_vpc_security_group.zabbix_server.id]
  }
  metadata = {
    "user-data" = templatefile("${path.module}/cloud-init.tftpl", {
      ssh_key  = var.ssh_public_key
      username = var.vm_user
      hostname = "zabbix-server"
    })
  }
  depends_on = [yandex_mdb_postgresql_cluster.zabbix]
  scheduling_policy {
    preemptible = true
  }
  labels = merge(local.labels, { role = "monitoring-server" })
}

resource "yandex_compute_instance" "zabbix_web" {
  name        = "zabbix-web"
  hostname    = "zabbix-web"
  zone        = local.zones.a
  platform_id = "standard-v3"
  resources {
    cores         = var.vm_sizes["small"].cores
    memory        = var.vm_sizes["small"].memory
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.vm_sizes["small"].disk
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.public_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.zabbix_web.id]
  }
  metadata = {
    "user-data" = templatefile("${path.module}/cloud-init.tftpl", {
      ssh_key  = var.ssh_public_key
      username = var.vm_user
      hostname = "zabbix-web"
    })
  }
  scheduling_policy {
    preemptible = true
  }
  labels = merge(local.labels, { role = "monitoring-frontend" })
}

resource "yandex_compute_instance" "elastic" {
  name        = "elasticsearch"
  hostname    = "elasticsearch"
  zone        = local.zones.a
  platform_id = "standard-v3"
  resources {
    cores         = var.vm_sizes["medium"].cores
    memory        = var.vm_sizes["medium"].memory
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.vm_sizes["large"].disk
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.private_a.id
    security_group_ids = [yandex_vpc_security_group.elastic.id]
  }
  metadata = {
    "user-data" = templatefile("${path.module}/cloud-init.tftpl", {
      ssh_key  = var.ssh_public_key
      username = var.vm_user
      hostname = "elasticsearch"
    })
  }
  scheduling_policy {
    preemptible = true
  }
  labels = merge(local.labels, { role = "logging-storage" })
}

resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  hostname    = "kibana"
  zone        = local.zones.a
  platform_id = "standard-v3"
  resources {
    cores         = var.vm_sizes["small"].cores
    memory        = var.vm_sizes["small"].memory
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.vm_sizes["small"].disk
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.public_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kibana.id]
  }
  metadata = {
    "user-data" = templatefile("${path.module}/cloud-init.tftpl", {
      ssh_key  = var.ssh_public_key
      username = var.vm_user
      hostname = "kibana"
    })
  }
  scheduling_policy {
    preemptible = true
  }
  labels = merge(local.labels, { role = "logging-frontend" })
}

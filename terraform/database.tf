resource "yandex_mdb_postgresql_cluster" "zabbix" {
  name               = "zabbix-db-cluster"
  environment        = "PRODUCTION"
  network_id         = yandex_vpc_network.main.id
  security_group_ids = [yandex_vpc_security_group.managed_db.id]
  
  config {
    version = "14"
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-hdd"
      disk_size          = 16
    }
  }
  
  host {
    zone      = local.zones.a
    subnet_id = yandex_vpc_subnet.private_a.id
  }
  
  host {
    zone      = local.zones.b
    subnet_id = yandex_vpc_subnet.private_b.id
  }
  
  labels = local.labels
}

resource "yandex_mdb_postgresql_database" "zabbix" {
  cluster_id = yandex_mdb_postgresql_cluster.zabbix.id
  name       = "zabbix"
  owner      = yandex_mdb_postgresql_user.zabbix.name
}

resource "yandex_mdb_postgresql_user" "zabbix" {
  cluster_id = yandex_mdb_postgresql_cluster.zabbix.id
  name       = "zabbix"
  password   = var.db_password
}

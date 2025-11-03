# Файл: terraform/provisioners.tf

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.yml"
  content  = <<-YAML
---
all:
  children:
    web:
      hosts:
        web-1.ru-central1.internal:
        web-2.ru-central1.internal:
    monitoring:
      hosts:
        zabbix-server.ru-central1.internal:
        zabbix-web.ru-central1.internal:
    logging:
      hosts:
        elasticsearch.ru-central1.internal:
        kibana.ru-central1.internal:
    bastion:
      hosts:
        bastion.ru-central1.internal:
  vars:
    pg_fqdn: "${yandex_mdb_postgresql_cluster.zabbix.host[0].fqdn}"
    alb_ip: "${yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address}"
  YAML
}
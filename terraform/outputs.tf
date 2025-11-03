output "info" {
  value = <<-EOT
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     INFRASTRUCTURE DEPLOYED!
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    PUBLIC ACCESS:
      Website:    http://${yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address}
      Zabbix:     http://${yandex_compute_instance.zabbix_web.network_interface[0].nat_ip_address}/zabbix
      Kibana:     http://${yandex_compute_instance.kibana.network_interface[0].nat_ip_address}:5601
    
    SSH ACCESS:
      Bastion:    ssh ${var.vm_user}@${yandex_compute_instance.bastion.network_interface[0].nat_ip_address}

    DATABASE (PgBouncer):
      PostgreSQL: ${yandex_mdb_postgresql_cluster.zabbix.host[0].fqdn}:6432
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  EOT
  description = "Quick access summary"
}

data "yandex_alb_target_group" "web" {
  name       = "web-target-group"
  depends_on = [yandex_compute_instance_group.web]
}

resource "yandex_alb_backend_group" "web" {
  name = "web-backend-group"
  
  http_backend {
    name             = "web-backend"
    port             = 80
    target_group_ids = [data.yandex_alb_target_group.web.id]
    
    healthcheck {
      timeout             = "3s"
      interval            = "5s"
      healthy_threshold   = 2
      unhealthy_threshold = 3
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "web" {
  name = "web-http-router"
}

resource "yandex_alb_virtual_host" "web" {
  name           = "web-vhost"
  http_router_id = yandex_alb_http_router.web.id
  
  route {
    name = "default-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web" {
  name               = "web-alb"
  network_id         = yandex_vpc_network.main.id
  security_group_ids = [yandex_vpc_security_group.alb.id]
  
  allocation_policy {
    location {
      zone_id   = local.zones.a
      subnet_id = yandex_vpc_subnet.public_a.id
    }
    location {
      zone_id   = local.zones.b
      subnet_id = yandex_vpc_subnet.public_b.id
    }
  }
  
  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }
  
  labels = local.labels
}

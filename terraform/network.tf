resource "yandex_vpc_network" "main" {
  name   = "diploma-network"
  labels = local.labels
}

resource "yandex_vpc_subnet" "public_a" {
  name           = "public-a"
  zone           = local.zones.a
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.1.0/24"]
  labels         = local.labels
}

resource "yandex_vpc_subnet" "public_b" {
  name           = "public-b"
  zone           = local.zones.b
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.2.0/24"]
  labels         = local.labels
}

resource "yandex_vpc_subnet" "private_a" {
  name           = "private-a"
  zone           = local.zones.a
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.10.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
  labels         = local.labels
}

resource "yandex_vpc_subnet" "private_b" {
  name           = "private-b"
  zone           = local.zones.b
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.20.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
  labels         = local.labels
}

resource "yandex_vpc_gateway" "nat" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private" {
  name       = "private-route"
  network_id = yandex_vpc_network.main.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

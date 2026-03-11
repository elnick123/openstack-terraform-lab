# External network 
data "openstack_networking_network_v2" "external" {
  name = local.external_network_name
}

# Private network 
resource "openstack_networking_network_v2" "private" {
  name           = local.private_net_name
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "private" {
  name            = local.private_subnet_name
  network_id      = openstack_networking_network_v2.private.id
  cidr            = local.private_cidr
  ip_version      = 4
  gateway_ip      = local.private_gateway_ip
  enable_dhcp     = true
  dns_nameservers = ["1.1.1.1", "8.8.8.8"]
}

# Router to connect private subnet to external network
resource "openstack_networking_router_v2" "router" {
  name                = local.router_name
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "router_int" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.private.id
}


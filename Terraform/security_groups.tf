# Bastion Security Group (SSH allowed only from VPN)
resource "openstack_networking_secgroup_v2" "sg_bastion" {
  name = "sg-grandlab-bastion"
}

resource "openstack_networking_secgroup_rule_v2" "bastion_ssh_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = local.vpn_cidr
  security_group_id = openstack_networking_secgroup_v2.sg_bastion.id
}

# Enabling ping
resource "openstack_networking_secgroup_rule_v2" "bastion_icmp_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = local.vpn_cidr
  security_group_id = openstack_networking_secgroup_v2.sg_bastion.id
}


# Internal Security Group (Gitea VM)
# SSH allowed only from Bastion Security Group
# Gitea web allowed only from VPN CIDR
resource "openstack_networking_secgroup_v2" "sg_internal" {
  name = "sg-grandlab-internal"
}

resource "openstack_networking_secgroup_rule_v2" "internal_ssh_from_bastion" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = openstack_networking_secgroup_v2.sg_bastion.id
  security_group_id = openstack_networking_secgroup_v2.sg_internal.id
}

resource "openstack_networking_secgroup_rule_v2" "gitea_web_from_vpn" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = local.gitea_port
  port_range_max    = local.gitea_port
  remote_ip_prefix  = local.vpn_cidr
  security_group_id = openstack_networking_secgroup_v2.sg_internal.id
}

# Enabling ping
resource "openstack_networking_secgroup_rule_v2" "internal_icmp_from_vpn" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = local.vpn_cidr
  security_group_id = openstack_networking_secgroup_v2.sg_internal.id
}


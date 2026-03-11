# Keypair 
resource "openstack_compute_keypair_v2" "kp" {
  name       = local.keypair_name
  public_key = file(pathexpand(local.public_key_path))
}


# Openstack Neutron network ports
resource "openstack_networking_port_v2" "bastion_port" {
  name       = "${local.bastion_name}-port"
  network_id = openstack_networking_network_v2.private.id

  security_group_ids = [
    openstack_networking_secgroup_v2.sg_bastion.id
  ]
}

resource "openstack_networking_port_v2" "gitea_port" {
  name       = "${local.gitea_name}-port"
  network_id = openstack_networking_network_v2.private.id

  security_group_ids = [
    openstack_networking_secgroup_v2.sg_internal.id
  ]
}


# Instances
resource "openstack_compute_instance_v2" "bastion" {
  name              = local.bastion_name
  flavor_name       = local.flavor_name
  key_pair          = openstack_compute_keypair_v2.kp.name
  availability_zone = "nova-2"

  network {
    port = openstack_networking_port_v2.bastion_port.id
  }

  block_device {
    uuid                  = local.debian_13_id
    source_type           = "image"
    volume_size           = 10
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
}

resource "openstack_compute_instance_v2" "gitea" {
  name              = local.gitea_name
  flavor_name       = local.flavor_name
  key_pair          = openstack_compute_keypair_v2.kp.name
  availability_zone = "nova-2"

  network {
    port = openstack_networking_port_v2.gitea_port.id
  }

  block_device {
    uuid                  = local.debian_13_id
    source_type           = "image"
    volume_size           = 10
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
}


# Floating IP for bastion
resource "openstack_networking_floatingip_v2" "bastion_fip" {
  pool = local.external_network_name
}

resource "openstack_networking_floatingip_associate_v2" "bastion_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.bastion_fip.address
  port_id     = openstack_networking_port_v2.bastion_port.id
}


# Floating IP for gitea
resource "openstack_networking_floatingip_v2" "gitea_fip" {
  pool = local.external_network_name
}

resource "openstack_networking_floatingip_associate_v2" "gitea_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.gitea_fip.address
  port_id     = openstack_networking_port_v2.gitea_port.id
}


# Outputs
output "bastion_public_ip" {
  value = openstack_networking_floatingip_v2.bastion_fip.address
}

output "bastion_private_ip" {
  value = openstack_networking_port_v2.bastion_port.all_fixed_ips[0]
}

output "gitea_private_ip" {
  value = openstack_networking_port_v2.gitea_port.all_fixed_ips[0]
}

output "gitea_public_ip" {
  value = openstack_networking_floatingip_v2.gitea_fip.address
}


locals {
  external_network_name = "external-net"

  # VPN CIDR
  vpn_cidr = "100.65.0.0/16"

  # Lab network
  private_net_name    = "grandlab-net"
  private_subnet_name = "grandlab-subnet"
  private_cidr        = "10.10.10.0/24"
  private_gateway_ip  = "10.10.10.1"
  router_name         = "grandlab-router"

  # Compute
  flavor_name  = "m1.small"
  debian_13_id = "67e184fb-1fb2-4ef8-8c04-a570a2f098c0"

  # SSH keypair that Terraform will create in OpenStack from local public key
  keypair_name    = "grandlab-key"
  public_key_path = "~/.ssh/grandlab_ed25519.pub"

  # Instance names
  bastion_name = "grandlab_bastion"
  gitea_name   = "grandlab_gitea"

  # Gitea port
  gitea_port = 3000
}


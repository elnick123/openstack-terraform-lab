# Grand Lab - Nikola Savic (ITS25GS)



## Project overview

The project deploys a working Gitea web app in an Openstack lab environment. The infrastructure is deployed with Terraform. Gitea is installed and configured manually via SSH after Terraform deployment.

Application

* Gitea (Docker + SQLite)
* Architecture:

  * Bastion VM
  * Gitea VM
  * SSH only via bastion
  * Gitea web reachable via Gitea VM floating IP and through VPN

## Requirements satisfied

* Infrastructure deployed with Terraform
* SSH to internal VM (Gitea) is allowed only from Bastion
* Floating IPs are used only where necessary
* Documentation and screenshots included, including a full browser window showing the app logged in and working, and git upload/download from the Ubuntu host.

## Architecture

VMs

* Bastion VM

  * Purpose: single entry point for SSH
  * Public/Floating IP: 198.18.1.77
  * Private IP: 10.10.10.144

* Gitea VM

  * Purpose: runs Gitea service (Docker)
  * Public/Floating IP: 198.18.0.104
  * Private IP: 10.10.10.110

Network

* Private network/subnet created with Terraform:

  * Subnet CIDR: 10.10.10.0/24
  * Router connected to external network: external-net

* VPN is required to access the lab environment.

Security

* SSH policy:

  * Bastion allows SSH from the VPN range
  * Gitea VM allows SSH only from the Bastion Security Group

* Web access policy:

  * Gitea is accessible via http://198.18.0.104:3000/ for the demo.

## Repository structure

grand-lab/
terraform/
provider.tf
locals.tf
network.tf
security_groups.tf
compute.tf
README.md

## Prerequisites

On the host running Terraform:

* VPN connected (WireGuard)
* Terraform installed
* OpenStack RC file downloaded
* SSH key created locally (public key uploaded to Openstack through Terraform)



## Terraform deployment instructions

### Load Openstack credentials

In the terminal:

source ~/rc/openrc.sh
env | grep '^OS\_' | head    # to check whether the file is sourced correctly

### From the Terraform folder:

cd ~/grand-lab/terraform
terraform fmt    # to auto-format .tf files into Terraform standard style
terraform validate
terraform init
terraform plan
terraform apply
terraform output

Outputs (example from my project):
bastion\_public\_ip = 198.18.1.77
bastion\_private\_ip = 10.10.10.144
gitea\_public\_ip = 198.18.0.104
gitea\_private\_ip = 10.10.10.110

If an error occurs, correct the Terraform configuration and re-run:

terraform plan
terraform apply

## Access and verification

### SSH access rules (Bastion-only SSH to internal VM)

Bastion must be used to access internal resources over SSH, and SSH must be allowed only from Bastion Security Group.

SSH to Bastion:
ssh debian@198.18.1.77

SSH to Gitea VM through Bastion:
ssh -J debian@198.18.1.77 debian@10.10.10.110

## Gitea installation (manual)

### Install Docker on the Gitea VM

SSH into the Gitea VM (via bastion), then run:

sudo apt update
sudo apt install -y ca-certificates curl

curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
newgrp docker

### Create Docker Compose file

sudo mkdir -p /opt/gitea
sudo nano /opt/gitea/compose.yml

services:
gitea:
image: gitea/gitea:latest
container\_name: gitea
restart: always
ports:
- "3000:3000"
volumes:
- gitea-data:/data

volumes:
gitea-data:

### Start Gitea

docker compose -f /opt/gitea/compose.yml up -d
docker ps

## Access the web UI

Open the site in a browser:

* Gitea URL: http://198.18.0.104:3000/

Complete the setup page:

* Database: SQLite3
* Create admin user

## Proof of functionality (upload \& download)

To demonstrate the service is working, I verified repository operations:

### Upload (push)

mkdir gitea-demo && cd gitea-demo
git init
echo "hello gitea" > test.txt
git add test.txt
git commit -m "Initial commit"
git branch -M main

git remote add origin http://198.18.0.104:3000/nikola/gitea-demo.git
git push -u origin main

### Download (clone)

cd ~
git clone http://198.18.0.104:3000/nikola/gitea-demo.git
cat gitea-demo/test.txt

## Notes/Troubleshooting

* If terraform plan fails with missing auth, re-source the OpenStack RC file in the same terminal session.
* If browser access times out, check:
  * security group allows port 3000 from VPN
  * container is running: docker ps
* SSH to internal VM should fail if attempted directly (not via bastion), which confirms bastion-only SSH enforcement.


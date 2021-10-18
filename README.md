# Dokku VM on Azure

## About

Quickly deploy a VM instance running Dokku on Azure using Terraform and Ansible

## Requirements

* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

### Prerequisites

Your public ssh key should be available at `~/.ssh/id_rsa.pub`  
If it's not, you can generate a key-pair using `ssh-keygen`

## Usage

Run ```bash deploy.sh``` to deploy your VM  
```bash teardown.sh``` can be used to remove all the deployed resources

VM ip will be stored in `ip.txt` after deployment, you can ssh to the vm using `ssh azureuser@ip_addr`

## Settings
* Adjust the VM [instance size](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes) and resource [deployment location](https://azure.microsoft.com/en-in/global-infrastructure/geographies/#geographies) in `main.tf`
* You can adjust the swap memory size under `swap.yml`

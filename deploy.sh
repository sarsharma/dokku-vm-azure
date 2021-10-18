#!/bin/bash
terraform init
terraform apply -var="public_ssh_key=$(cat ~/.ssh/id_rsa.pub)" -auto-approve
ansible-galaxy install dokku_bot.ansible_dokku 
# allow time for VM to become ready to accept ssh connection
#ToDo remove hardcoded sleep
sleep 1m
ansible-playbook -i azureuser@$(cat ip.txt),  dokku_deploy.yml 
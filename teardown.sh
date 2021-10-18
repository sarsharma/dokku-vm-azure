#!/bin/bash
terraform destroy -var="public_ssh_key=$(cat ~/.ssh/id_rsa.pub)" -auto-approve
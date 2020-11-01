#!/bin/bash

cd terraform
terraform apply -auto-approve

#Generate ansible hosts file
bash generate_ansible_hosts.sh

cd -
cd ansible
ansible-playbook -i hosts ansible.yaml

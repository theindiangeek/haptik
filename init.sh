#!/bin/bash

cd terraform
terraform destroy -auto-approve
terraform apply -auto-approve

#Wait until 2 mins so that ec2 init scripts run
sleep 120

#Generate ansible hosts file
bash generate_ansible_hosts.sh

cd -
cd ansible
ansible-playbook -i hosts ansible.yaml

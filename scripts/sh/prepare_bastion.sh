#!/usr/bin/env bash

ansible_bastion_url=$(aws ec2 describe-instances \
    --filters \
    "Name=tag:Name,Values=ansible_bastion" \
    "Name=instance-state-name,Values=running" \
    | jq '.Reservations | .[0] | .Instances | .[0] | .PublicDnsName' \
    | sed 's/\"//g')
scp -i ~/.ssh/ansible -o StrictHostKeyChecking=no ~/.ssh/jenkins_env_key ansible@$ansible_bastion_url:/home/ansible/.ssh/jenkins_env_key
ssh -i ~/.ssh/ansible -o StrictHostKeyChecking=no ansible@$ansible_bastion_url chmod 0400 /home/ansible/.ssh/jenkins_env_key
echo "SSH to the Bastion with: ssh -i ~/.ssh/ansible ansible@$ansible_bastion_url"

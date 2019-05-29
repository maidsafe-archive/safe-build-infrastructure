#!/usr/bin/env bash

cloud_environment=$1
if [[ -z "$cloud_environment" ]]; then
    echo "A value must be supplied for the target environment. Valid values are 'dev', 'staging' or 'prod'."
    exit 1
fi

ansible_bastion_url=$(aws ec2 describe-instances \
    --filters \
    "Name=tag:Name,Values=ansible_bastion" \
    "Name=instance-state-name,Values=running" \
    | jq '.Reservations | .[0] | .Instances | .[0] | .PublicDnsName' \
    | sed 's/\"//g')
scp -i "$HOME/.ssh/ansible_$cloud_environment" -o StrictHostKeyChecking=no ~/.ssh/jenkins_prod ansible@$ansible_bastion_url:/home/ansible/.ssh/jenkins_prod
scp -i "$HOME/.ssh/ansible_$cloud_environment" -o StrictHostKeyChecking=no ~/.ssh/windows_slave_prod ansible@$ansible_bastion_url:/home/ansible/.ssh/windows_slave_prod
scp -i "$HOME/.ssh/ansible_$cloud_environment" -o StrictHostKeyChecking=no ~/.ssh/ansible_prod ansible@$ansible_bastion_url:/home/ansible/.ssh/ansible_prod
ssh -i "$HOME/.ssh/ansible_$cloud_environment" -o StrictHostKeyChecking=no ansible@$ansible_bastion_url chmod 0400 /home/ansible/.ssh/jenkins_prod
ssh -i "$HOME/.ssh/ansible_$cloud_environment" -o StrictHostKeyChecking=no ansible@$ansible_bastion_url chmod 0400 /home/ansible/.ssh/windows_slave_prod
ssh -i "$HOME/.ssh/ansible_$cloud_environment" -o StrictHostKeyChecking=no ansible@$ansible_bastion_url chmod 0400 /home/ansible/.ssh/ansible_prod
echo "SSH to the Bastion with: ssh -i ~/.ssh/ansible_$cloud_environment ansible@$ansible_bastion_url"

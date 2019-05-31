#!/usr/bin/env bash

cloud_environment=$1
if [[ -z "$cloud_environment" ]]; then
    echo "A value must be supplied for the target environment. Valid values are 'dev', 'staging' or 'prod'."
    exit 1
fi

ansible_bastion_url=$(aws ec2 describe-instances \
    --filters \
    "Name=tag:Name,Values=ansible_bastion" \
    "Name=tag:environment,Values=$cloud_environment" \
    "Name=instance-state-name,Values=running" \
    | jq '.Reservations | .[0] | .Instances | .[0] | .PublicDnsName' \
    | sed 's/\"//g')
scp -i "$HOME/.ssh/ansible_$cloud_environment" -o StrictHostKeyChecking=no "$HOME/.ssh/jenkins_$cloud_environment" ansible@"$ansible_bastion_url:/home/ansible/.ssh/jenkins_$cloud_environment"
scp -i "$HOME/.ssh/ansible_$cloud_environment" -o StrictHostKeyChecking=no "$HOME/.ssh/windows_slave_$cloud_environment" ansible@"$ansible_bastion_url:/home/ansible/.ssh/windows_slave_$cloud_environment"
scp -i "$HOME/.ssh/ansible_$cloud_environment" -o StrictHostKeyChecking=no "$HOME/.ssh/ansible_$cloud_environment" ansible@"$ansible_bastion_url:/home/ansible/.ssh/ansible_$cloud_environment"
ssh -i "$HOME/.ssh/ansible_$cloud_environment" -o StrictHostKeyChecking=no ansible@$ansible_bastion_url chmod 0400 "/home/ansible/.ssh/jenkins_$cloud_environment"
ssh -i "$HOME/.ssh/ansible_$cloud_environment" -o StrictHostKeyChecking=no ansible@$ansible_bastion_url chmod 0400 "/home/ansible/.ssh/windows_slave_$cloud_environment"
ssh -i "$HOME/.ssh/ansible_$cloud_environment" -o StrictHostKeyChecking=no ansible@$ansible_bastion_url chmod 0400 "/home/ansible/.ssh/ansible_$cloud_environment"
echo "SSH to the Bastion with: ssh -i ~/.ssh/ansible_$cloud_environment ansible@$ansible_bastion_url"

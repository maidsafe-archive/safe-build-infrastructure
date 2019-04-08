#!/usr/bin/env bash

ansible_bastion_url=$(aws ec2 describe-instances \
    --filters \
    "Name=tag:Name,Values=ansible_bastion" \
    "Name=instance-state-name,Values=running" \
    | jq '.Reservations | .[0] | .Instances | .[0] | .PublicDnsName' \
    | sed 's/\"//g')
echo "SSH to the Bastion with: ssh -i ~/.ssh/ansible ansible@$ansible_bastion_url"

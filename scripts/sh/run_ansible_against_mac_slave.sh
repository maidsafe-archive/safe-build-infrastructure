#!/bin/bash

set -e

jenkins_master_dns=$(aws ec2 describe-instances \
    --filters \
    "Name=tag:Name,Values=jenkins_master" \
    "Name=instance-state-name,Values=running" \
    | jq '.Reservations | .[0] | .Instances | .[0] | .PublicDnsName' \
    | sed 's/\"//g')
echo "Jenkins master is at $jenkins_master_dns"
echo "Attempting Ansible run against macOS slave... (can be 10+ seconds before output)"
ANSIBLE_SSH_PIPELINING=true ansible-playbook -i environments/prod/hosts \
    --limit=macos_rust_slave \
    --vault-password-file=~/.ansible/vault-pass \
    --private-key=~/.ssh/id_rsa \
    -e "wg_server_endpoint=$jenkins_master_dns" \
    -e "cloud_environment=prod" \
    ansible/osx-rust-slave.yml

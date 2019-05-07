#!/bin/bash

nc -z -vvv jenkins.maidsafe.net 80
rc=$?

if [[ $rc == 0 ]]; then
    proxy_dns="jenkins.maidsafe.net"
else
    proxy_dns=$(aws ec2 describe-instances \
        --filters \
        "Name=tag:Name,Values=haproxy" \
        "Name=tag:environment,Values=prod" \
        "Name=instance-state-name,Values=running" \
        | jq '.Reservations | .[0] | .Instances | .[0] | .PublicDnsName' \
        | sed 's/\"//g')
fi

echo "Jenkins master is at $proxy_dns"
echo "Attempting Ansible run against macOS slave... (can be 10+ seconds before output)"
ANSIBLE_SSH_PIPELINING=true ansible-playbook -i environments/prod/hosts \
    --limit=macos_rust_slave \
    --vault-password-file=~/.ansible/vault-pass \
    --private-key=~/.ssh/id_rsa \
    -e "wg_server_endpoint=$proxy_dns" \
    -e "cloud_environment=prod" \
    ansible/osx-rust-slave.yml

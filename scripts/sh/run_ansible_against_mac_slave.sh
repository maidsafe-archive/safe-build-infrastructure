#!/bin/bash

cloud_environment=$1
if [[ -z "$cloud_environment" ]]; then
    echo "A value must be supplied for the target environment. Valid values are 'dev', 'staging' or 'prod'."
    exit 1
fi

function get_proxy_dns() {
    if [[ "$cloud_environment" == "prod" ]]; then
        proxy_dns="jenkins.maidsafe.net"
    elif [[ "$cloud_environment" == "staging" ]]; then
        proxy_dns="jenkins-staging.maidsafe.net"
    elif [[ "$cloud_environment" == "qa" ]]; then
        proxy_dns="jenkins-qa.maidsafe.net"
    else
        proxy_dns=$(aws ec2 describe-instances \
            --filters \
            "Name=tag:Name,Values=jenkins_master" \
            "Name=tag:environment,Values=$cloud_environment" \
            "Name=instance-state-name,Values=running" \
            | jq '.Reservations | .[0] | .Instances | .[0] | .PublicDnsName' \
            | sed 's/\"//g')
    fi
    echo "Jenkins master is at $proxy_dns"
}

function run_ansible() {
    echo "Jenkins master is at $proxy_dns"
    echo "Attempting Ansible run against macOS slave... (can be 10+ seconds before output)"
    ANSIBLE_SSH_PIPELINING=true ansible-playbook -i "environments/$cloud_environment" \
        --limit=osx_slaves \
        --vault-password-file=~/.ansible/vault-pass \
        --private-key=~/.ssh/id_rsa \
        -e "wg_server_endpoint=$proxy_dns" \
        -e "cloud_environment=$cloud_environment" \
        -e "wg_run_on_host=True" \
        ansible/osx-rust-slave.yml
}

get_proxy_dns
run_ansible

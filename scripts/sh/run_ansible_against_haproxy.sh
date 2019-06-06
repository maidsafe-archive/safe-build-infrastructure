#!/usr/bin/env bash

set -e

cloud_environment=$1
if [[ -z "$cloud_environment" ]]; then
    echo "A value must be supplied for the target environment. Valid values are 'dev' or 'prod'."
    exit 1
fi

ansible_ssh_key="$HOME/.ssh/ansible_$cloud_environment"

ec2_ini_file=$2
if [[ -z "$ec2_ini_file" ]]; then
    ec2_ini_file="ec2.ini"
fi

function get_proxy_location() {
    if [[ "$cloud_environment" == "qa" ]]; then
        proxy_dns=$(aws ec2 describe-instances \
            --filters \
            "Name=tag:Name,Values=haproxy" \
            "Name=tag:environment,Values=$cloud_environment" \
            "Name=instance-state-name,Values=running" \
            | jq '.Reservations | .[0] | .Instances | .[0] | .PublicDnsName' \
            | sed 's/\"//g')
        jenkins_url="https://$proxy_dns"
    fi
}

function run_ansible() {
    rm -rf ~/.ansible/tmp
    echo "Running Ansible against proxy instance... (can be 10+ seconds before output)"
    if [[ "$cloud_environment" == "qa" ]]; then
        get_proxy_location
        EC2_INI_PATH="environments/$cloud_environment/$ec2_ini_file" \
            ansible-playbook -i "environments/$cloud_environment" \
            --private-key="$ansible_ssh_key" \
            --limit=haproxy \
            --vault-password-file=~/.ansible/vault-pass \
            -e "cloud_environment=$cloud_environment" \
            -e "jenkins_url=$jenkins_url" \
            -e "wg_run_on_host=True" \
            -u ansible ansible/proxy.yml
    else
        EC2_INI_PATH="environments/$cloud_environment/$ec2_ini_file" \
            ansible-playbook -i "environments/$cloud_environment" \
            --private-key="$ansible_ssh_key" \
            --limit=haproxy \
            --vault-password-file=~/.ansible/vault-pass \
            -e "cloud_environment=$cloud_environment" \
            -e "wg_run_on_host=True" \
            -u ansible ansible/proxy.yml
    fi
}

run_ansible

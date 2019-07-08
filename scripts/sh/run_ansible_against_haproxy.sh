#!/usr/bin/env bash

set -e

cloud_environment=$1
if [[ -z "$cloud_environment" ]]; then
    echo "A value must be supplied for the target environment. Valid values are 'dev' or 'prod'."
    exit 1
fi

run_mode=$2
if [[ -z "$run_mode" ]]; then
    echo "A value must be supplied for the run mode. Valid values are 'initial' or 'reprovision'."
    exit 1
fi

ansible_ssh_key="$HOME/.ssh/ansible_$cloud_environment"

ec2_ini_file=$3
if [[ -z "$ec2_ini_file" ]]; then
    ec2_ini_file="ec2.ini"
fi

rm -rf ~/.ansible/tmp
echo "Running Ansible against proxy instance... (can be 10+ seconds before output)"
EC2_INI_PATH="environments/$cloud_environment/$ec2_ini_file" \
    ansible-playbook -i "environments/$cloud_environment" \
    --private-key="$ansible_ssh_key" \
    --limit=haproxy \
    --vault-password-file=~/.ansible/vault-pass \
    -e "run_mode=$run_mode" \
    -e "cloud_environment=$cloud_environment" \
    -e "wg_run_on_host=True" \
    -u ansible ansible/proxy.yml

#!/bin/bash

set -e

cloud_environment=$1
if [[ -z "$cloud_environment" ]]; then
    echo "A value must be supplied for the target environment. Valid values are 'dev' or 'prod'."
    exit 1
fi

windows_slave_key_path="$HOME/.ssh/windows_slave_$cloud_environment"

ec2_ini_file=$2
if [[ -z "$ec2_ini_file" ]]; then
    ec2_ini_file="ec2.ini"
fi

function get_instance_ids() {
    mapfile -t instance_ids < <(aws ec2 describe-instances \
        --filters \
        "Name=tag:Name,Values=windows_slave*" \
        "Name=tag:environment,Values=$cloud_environment" \
        "Name=instance-state-name,Values=running" \
        | jq '.Reservations | .[] | .Instances | .[] | .InstanceId' \
        | sed 's/\"//g')
}

function get_instance_password() {
    local instance_id="$1"
    local response
    response=$(aws ec2 get-password-data \
        --region eu-west-2 \
        --instance-id "$instance_id" \
        --priv-launch-key "$windows_slave_key_path")
    password=$(jq '.PasswordData' <<< "$response" | sed 's/\"//g')
    while [[ $password == "" ]]
    do
        response=$(aws ec2 get-password-data \
            --region eu-west-2 \
            --instance-id "$instance_id" \
            --priv-launch-key "$windows_slave_key_path")
        password=$(jq '.PasswordData' <<< "$response" | sed 's/\"//g')
        echo "Password for instance not yet available. Waiting for 5 seconds before retry."
        sleep 5
    done
    echo "Password retrieved for Windows instance."
}

function run_ansible() {
    rm -rf ~/.ansible/tmp
    local count=1
    for instance_id in "${instance_ids[@]}"
    do
        get_instance_password "$instance_id"
        echo "Setting ansible user password for Windows slave... (can be 10+ seconds before output)"
        EC2_INI_PATH="environments/$cloud_environment/$ec2_ini_file" \
            ansible-playbook -i "environments/$cloud_environment" \
            --vault-password-file=~/.ansible/vault-pass \
            --limit="windows_slave_00$count" \
            -e "ansible_user=Administrator" \
            -e "ansible_password=$password" \
            -e "admin_password=$password" \
            ansible/win-ansible-user.yml
        ((count++))
    done
}

get_instance_ids
run_ansible

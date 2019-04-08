#!/usr/bin/env bash

set -e

function get_instance_id() {
    instance_id=$(aws ec2 describe-instances \
        --filters \
        "Name=tag:Name,Values=windows_slave_001" \
        "Name=tag:environment,Values=dev" \
        "Name=instance-state-name,Values=running" \
        | jq '.Reservations | .[0] | .Instances | .[0] | .InstanceId' \
        | sed 's/\"//g')
}

function get_instance_password() {
    local response
    response=$(aws ec2 get-password-data \
        --region eu-west-2 \
        --instance-id "$instance_id" \
        --priv-launch-key ~/.ssh/jenkins_env_key)
    password=$(jq '.PasswordData' <<< "$response" | sed 's/\"//g')
    while [[ $password == "" ]]
    do
        response=$(aws ec2 get-password-data \
            --region eu-west-2 \
            --instance-id "$instance_id" \
            --priv-launch-key ~/.ssh/jenkins_env_key)
        password=$(jq '.PasswordData' <<< "$response" | sed 's/\"//g')
        echo "Password for instance not yet available. Waiting for 5 seconds before retry."
        sleep 5
    done
    echo "Password retrieved for Windows instance."
}

function get_jenkins_url() {
    jenkins_master_url=$(aws ec2 describe-instances \
        --filters \
        "Name=tag:Name,Values=jenkins_master" \
        "Name=instance-state-name,Values=running" \
        | jq '.Reservations | .[0] | .Instances | .[0] | .PublicDnsName' \
        | sed 's/\"//g')
    echo "Jenkins master is at $jenkins_master_url"
}

function run_ansible() {
    EC2_INI_PATH=/etc/ansible/ec2.ini ansible-playbook -i environments/prod \
        --vault-password-file=~/.ansible/vault-pass \
        -e "cloud_environment=true" \
        -e "ansible_password=$password" \
        -e "jenkins_master_url=$jenkins_master_url" \
        ansible/win-jenkins-slave.yml
}

get_instance_id
get_jenkins_url
run_ansible

#!/bin/bash

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

function run_ansible() {
    jenkins_master_url=$(aws ec2 describe-instances \
        --filters \
        "Name=tag:Name,Values=jenkins_master" \
        "Name=instance-state-name,Values=running" \
        | jq '.Reservations | .[0] | .Instances | .[0] | .PublicDnsName' \
        | sed 's/\"//g')
    echo "Jenkins master is at $jenkins_master_url"
    echo "Attempting Ansible run against Windows slave... (can be 10+ seconds before output)"
    rm -rf ~/.ansible/tmp
    EC2_INI_PATH=/etc/ansible/ec2.ini ansible-playbook -i environments/dev \
        --vault-password-file=~/.ansible/vault-pass \
		--private-key=~/.ssh/jenkins_env_key \
        -e "cloud_environment=true" \
        -e "ansible_password=$password" \
        -e "jenkins_master_url=$jenkins_master_url" \
        ansible/win-jenkins-slave.yml
}

function reboot_instance() {
    echo "Rebooting instance for necessary changes to take effect."
    echo "The Jenkins GUI will indicate when the machine becomes available again."
    aws ec2 reboot-instances --region eu-west-2 --instance-ids "$instance_id"
}

get_instance_id
get_instance_password
run_ansible
reboot_instance

echo "You can connect to Jenkins at http://$jenkins_master_url:8080/."

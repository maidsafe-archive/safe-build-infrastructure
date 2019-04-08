#!/usr/bin/env bash

set -e

function get_subnet_id() {
    subnet_id=$(aws ec2 describe-subnets \
        --filters \
        "Name=tag:Name,Values=jenkins_environment-private-eu-west-2a" \
        | jq '.Subnets | .[0] | .SubnetId' \
        | sed 's/\"//g')
    echo "Retrieved subnet ID for slaves as $subnet_id"
}

function run_ansible() {
    rm -rf ~/.ansible/tmp
    echo "Running Ansible against Jenkins master... (can be 10+ seconds before output)"
    EC2_INI_PATH=/etc/ansible/ec2.ini ansible-playbook -i environments/prod \
        --limit=jenkins_master \
        --vault-password-file=~/.ansible/vault-pass \
        -e "cloud_environment=prod" \
        -e "slave_vpc_subnet_id=$subnet_id" \
        -u ansible ansible/jenkins-master.yml
}

get_subnet_id
run_ansible

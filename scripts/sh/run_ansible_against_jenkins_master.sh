#!/usr/bin/env bash

set -e

cloud_environment=$1
if [[ -z "$cloud_environment" ]]; then
    echo "A value must be supplied for the target environment. Valid values are 'dev' or 'prod'."
    exit 1
fi

ec2_ini_file=$2
if [[ -z "$ec2_ini_file" ]]; then
    ec2_ini_file="ec2.ini"
fi

function get_jenkins_master_dns() {
    jenkins_master_dns=$(aws ec2 describe-instances \
        --filters \
        "Name=tag:Name,Values=jenkins_master" \
        "Name=tag:environment,Values=$cloud_environment" \
        "Name=instance-state-name,Values=running" \
        | jq '.Reservations | .[0] | .Instances | .[0] | .PublicDnsName' \
        | sed 's/\"//g')
    echo "Jenkins master is at $jenkins_master_dns"
}

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
    EC2_INI_PATH="environments/$cloud_environment/$ec2_ini_file" \
        ansible-playbook -i "environments/$cloud_environment" \
        --private-key=~/.ssh/ansible \
        --limit=jenkins_master \
        --vault-password-file=~/.ansible/vault-pass \
        -e "cloud_environment=$cloud_environment" \
        -e "jenkins_master_url=http://$jenkins_master_dns/" \
        -e "slave_vpc_subnet_id=$subnet_id" \
        -u ansible ansible/jenkins-master.yml
}

get_jenkins_master_dns
[[ "$cloud_environment" == "prod" ]] && get_subnet_id
run_ansible

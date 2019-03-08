#!/bin/bash

set -e

declare -a jenkins_ports=(22 8080 50000)
declare -a windows_ports=(3389 5985 5986)

function create_security_groups() {
    echo "Creating jenkins_master-dev security group."
    local response
    response=$(aws ec2 create-security-group \
        --region eu-west-2 \
        --group-name jenkins_master-dev \
        --description "Ports required for Jenkins master" \
        --vpc-id vpc-f124b999)
    jenkins_group_id=$(jq '.GroupId' <<< "$response" | sed 's/\"//g')

    echo "$jenkins_group_id" > .aws_provision/jenkins_security_group_id
    echo "Creating windows_slaves-dev security group."
    response=$(aws ec2 create-security-group \
        --region eu-west-2 \
        --group-name windows_slaves-dev \
        --description "Ports required for Windows slaves" \
        --vpc-id vpc-f124b999)
    windows_slaves_group_id=$(jq '.GroupId' <<< "$response" | sed 's/\"//g')
    echo "$windows_slaves_group_id" > .aws_provision/windows_slaves_security_group_id
}

function open_ports() {
    for port in "${jenkins_ports[@]}"
    do
        echo "Opening port $port on jenkins group."
        aws ec2 authorize-security-group-ingress \
            --region eu-west-2 \
            --group-id "$jenkins_group_id" \
            --protocol tcp \
            --port "$port" \
            --cidr 0.0.0.0/0
    done
    aws ec2 authorize-security-group-ingress \
        --region eu-west-2 \
        --group-id "$jenkins_group_id" \
        --protocol udp \
        --port "51820" \
        --cidr 0.0.0.0/0
    for port in "${windows_ports[@]}"
    do
        echo "Opening port $port on windows slaves group."
        aws ec2 authorize-security-group-ingress \
            --region eu-west-2 \
            --group-id "$windows_slaves_group_id" \
            --protocol tcp \
            --port "$port" \
            --cidr 0.0.0.0/0
    done
}

[[ ! -d ".aws_provision" ]] && mkdir .aws_provision
create_security_groups
open_ports

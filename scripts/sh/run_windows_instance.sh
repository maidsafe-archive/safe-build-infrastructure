#!/bin/bash

# Helper script for spinning up a Windows Server 2016 on EC2.
#
# If you want to run this manually, i.e. outside the Makefile, run it
# from the root of this repository. There's a reference to another script
# that is assuming it's being run from the root of the repository.
# The script in question installs WinRM on the machine, which is what
# Ansible uses to connect to a Windows machine (it doesn't support SSH for Windows).
#
# Before you can run Ansible against the machine, you need to wait for
# the Administrator password to become available. This generally takes a few minutes.
# You need to supply this and the URL of the Jenkins master to the Ansible run, since
# the Jenkins agent service will attempt to connect to the master.

set -e

function create_instance() {
    echo "Spinning up Windows instance..."
    local response
    response=$(aws ec2 run-instances \
        --region eu-west-2 \
        --image-id ami-0186531b707ced2ef \
        --count 1 \
        --instance-type t3.small \
        --key-name personal \
        --security-group-ids sg-01281f5db1734b698 \
        --subnet-id subnet-b3298ac9 \
        --user-data file://scripts/ps/setup_winrm.ps1)
    instance_id=$(jq '.Instances | .[0] .InstanceId' <<< "$response" | sed 's/\"//g')
    aws ec2 create-tags \
        --region eu-west-2 \
        --resources "$instance_id" --tags \
        "Key=Name,Value=windows_slave_01" "Key=full_name,Value=rust_slave-windows-2016-x86_64" \
        "Key=group,Value=windows_slaves" "Key=environment,Value=dev"
    echo "$instance_id" > .aws_provision/instance_id
}

function wait_for_password_to_become_available() {
    local response
    response=$(aws ec2 get-password-data \
        --region eu-west-2 \
        --instance-id "$instance_id" \
        --priv-launch-key ~/.ssh/jenkins_key)
    password=$(jq '.PasswordData' <<< "$response" | sed 's/\"//g')
    while [[ $password == "" ]]
    do
        response=$(aws ec2 get-password-data \
            --region eu-west-2 \
            --instance-id "$instance_id" \
            --priv-launch-key ~/.ssh/jenkins_key)
        password=$(jq '.PasswordData' <<< "$response" | sed 's/\"//g')
        echo "Password for instance not yet available. Waiting for 5 seconds before retry."
        sleep 5
    done
    echo "Password retrieved."
    echo "$password" > .aws_provision/instance_password
}

[[ ! -d ".aws_provision" ]] && mkdir .aws_provision
create_instance
wait_for_password_to_become_available

#!/usr/bin/env bash

set -e

machine_name=$1
if [[ -z "$machine_name" ]]; then
    echo "A value for the machine name must be supplied."
    exit 1
fi

key_name=$2
if [[ -z "$key_name" ]]; then
    echo "A value for the key name must be supplied."
    exit 1
fi

function get_machine_location() {
    if [[ "$machine_name" == *"bastion"* ]]; then
        field_name="PublicDnsName"
    else
        field_name="PrivateIpAddress"
    fi
    location=$(aws ec2 describe-instances \
        --filters \
        "Name=tag:Name,Values=$machine_name" \
        "Name=instance-state-name,Values=running" \
        | jq ".Reservations | .[0] | .Instances | .[0] | .$field_name" \
        | sed 's/\"//g')
}

function wait_for_ssh() {
    ssh -i ~/.ssh/ansible_prod -o StrictHostKeyChecking=no ansible@"$location" ls
    rc=$?
    while [[ $rc != 0 ]]
    do
        ssh -i ~/.ssh/ansible_prod -o StrictHostKeyChecking=no ansible@"$location" ls
        rc=$?
        echo "SSH not yet available on $location, sleeping for 5 seconds before retry..."
    done
    echo "SSH available on $location, now running apt-get update..."
}

function run_update() {
    if [[ "$machine_name" == *"bastion"* ]]; then
        echo "Running yum update against $machine_name"
        ssh -i "$HOME/.ssh/$key_name" -o StrictHostKeyChecking=no ansible@"$location" sudo yum update -y
    else
        echo "Running apt-get update against $machine_name"
        ssh -i "$HOME/.ssh/$key_name" -o StrictHostKeyChecking=no ansible@"$location" sudo apt-get update -y
        echo "Running Python install against $machine_name"
        ssh -i "$HOME/.ssh/$key_name" -o StrictHostKeyChecking=no ansible@"$location" sudo apt-get install -y python
    fi
}

get_machine_location
wait_for_ssh
run_update

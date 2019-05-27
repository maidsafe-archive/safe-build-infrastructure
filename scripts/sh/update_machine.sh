#!/usr/bin/env bash

machine_name=$1
if [[ -z "$machine_name" ]]; then
    echo "A value for the machine name must be supplied."
    exit 1
fi

cloud_environment=$2
if [[ -z "$cloud_environment" ]]; then
    echo "A value for the environment must be supplied. Valid values are 'dev' or 'prod'."
    exit 1
fi

key_path=$3
if [[ -z "$key_path" ]]; then
    key_path="$HOME/.ssh/ansible_$cloud_environment"
fi

function get_machine_location() {
    if [[ "$machine_name" == *"bastion"* || "$cloud_environment" == "dev" ]]; then
        field_name="PublicDnsName"
    else
        field_name="PrivateIpAddress"
    fi
    location=$(aws ec2 describe-instances \
        --filters \
        "Name=tag:Name,Values=$machine_name" \
        "Name=tag:environment,Values=$cloud_environment" \
        "Name=instance-state-name,Values=running" \
        | jq ".Reservations | .[0] | .Instances | .[0] | .$field_name" \
        | sed 's/\"//g')
}

function get_machine_image_name() {
    local image_id
    image_id=$(aws ec2 describe-instances \
        --filters \
        "Name=tag:Name,Values=$machine_name" \
        "Name=tag:environment,Values=$cloud_environment" \
        "Name=instance-state-name,Values=running" \
        | jq ".Reservations | .[0] | .Instances | .[0] | .ImageId" \
        | sed 's/\"//g')
    image_name=$(aws ec2 describe-images --image-ids "$image_id" \
        | jq ".Images[0] | .Name" \
        | sed 's/\"//g')
    echo "Machine using $image_name"
}

function wait_for_ssh() {
    ssh -i "$key_path" -o StrictHostKeyChecking=no ansible@"$location" ls
    rc=$?
    while [[ $rc != 0 ]]
    do
        echo "SSH not yet available on $location, sleeping for 5 seconds before retry..."
        sleep 5
        ssh -i "$key_path" -o StrictHostKeyChecking=no ansible@"$location" ls
        rc=$?
    done
    echo "SSH available on $location, now running apt-get update..."
}

function run_update() {
    if [[ "$image_name" == *"CentOS"* ]]; then
        echo "Running yum update against $machine_name"
        ssh -i "$key_path" -o StrictHostKeyChecking=no ansible@"$location" sudo yum update -y
    elif [[ "$image_name" == *"ubuntu"* ]]; then
        echo "Running apt-get update and apt-get upgrade against $machine_name"
        ssh -i "$key_path" -o StrictHostKeyChecking=no ansible@"$location" sudo locale-gen en_GB.UTF-8
        ssh -i "$key_path" -o StrictHostKeyChecking=no ansible@"$location" sudo apt-get update -y
        ssh -i "$key_path" -o StrictHostKeyChecking=no ansible@"$location" sudo apt-get upgrade -y
        echo "Running Python install against $machine_name"
        ssh -i "$key_path" -o StrictHostKeyChecking=no ansible@"$location" sudo apt-get install -y python
    else
        echo "$image_name not yet supported. Please extend this script to add support."
        exit 1
    fi
}

get_machine_image_name
get_machine_location
wait_for_ssh
run_update

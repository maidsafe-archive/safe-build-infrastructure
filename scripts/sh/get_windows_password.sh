#!/bin/bash

cloud_environment=$1
if [[ -z "$cloud_environment" ]]; then
    echo "A value must be supplied for the target environment. Valid values are 'dev' or 'prod'."
    exit 1
fi

instance_id=$2
if [[ -z "$instance_id" ]]; then
    echo "A value must be supplied for the instance ID."
    exit 1
fi
windows_slave_key_path="$HOME/.ssh/windows_slave_$cloud_environment"

response=$(aws ec2 get-password-data \
    --region eu-west-2 \
    --instance-id "$instance_id" \
    --priv-launch-key "$windows_slave_key_path")
jq '.PasswordData' <<< "$response" | sed 's/\"//g'

#!/usr/bin/env bash

cloud_environment=$1
if [[ -z "$cloud_environment" ]]; then
    echo "A value must be supplied for the target environment. Valid values are 'dev', 'prod' or 'staging'."
    exit 1
fi

function get_instance_ids() {
  mapfile -t instance_ids < <(aws ec2 describe-instances \
    --filters \
    "Name=tag:environment,Values=$cloud_environment" \
    "Name=instance-state-name,Values=running" \
    | jq '.Reservations | .[] | .Instances | .[] | .InstanceId' \
    | sed 's/\"//g')

  echo "Instance IDs found: " "${instance_ids[@]}"
}

function reboot_instance() {
  for id in "${instance_ids[@]}";
  do
    echo "Rebooting instance" "$id" "for necessary updates to take effect."
    aws ec2 reboot-instances --region eu-west-2 --instance-ids "$id"
  done
  echo "Your environment will be available once the reboot process has complete"
}

# TODO add function wait_for_jenkins()

get_instance_ids
reboot_instance

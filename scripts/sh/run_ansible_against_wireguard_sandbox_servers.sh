#!/bin/bash

set -e

ssh_options=$(echo "-o UserKnownHostsFile=/dev/null \
    -o IdentitiesOnly=yes \
    -o IdentityFile=.vagrant/machines/wgclient-centos-7.6-x86_64/virtualbox/private_key \
    -o ControlMaster=auto \
    -o ControlPersist=60s")

function run_against_client() {
    ANSIBLE_HOST_KEY_CHECKING=false \
    ANSIBLE_SSH_ARGS="$ssh_options" \
    ansible-playbook --connection=ssh --timeout=30 --extra-vars=ansible_user='vagrant' \
        --limit="wgclient-centos-7.6-x86_64" \
        --inventory-file=environments/dev/hosts \
        --vault-password-file=~/.ansible/vault-pass \
        -e "wg_server_endpoint=$server_hostname" \
        ansible/wireguard-client.yml
}

function run_against_server() {
    rm -rf ~/.ansible/tmp
    ansible-playbook --connection=ssh --timeout=30 --user='centos' \
        --limit="wgserver" \
        --inventory-file=environments/dev \
        --vault-password-file=~/.ansible/vault-pass \
        ansible/wireguard-server.yml
}

server_hostname=$(vagrant ssh-config wgserver-centos-7.6-x86_64-aws | \
    grep "HostName" | awk '{ print $2 }')
run_against_server
run_against_client

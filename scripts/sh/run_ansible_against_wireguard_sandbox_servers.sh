#!/bin/bash

set -e

mode=$1

if [[ -z $mode ]]; then
    echo "Please provide a mode for the sandbox. Valid values are either vbox or mac."
    exit 1
fi

ssh_options=$(echo "-o UserKnownHostsFile=/dev/null \
    -o IdentitiesOnly=yes \
    -o IdentityFile=.vagrant/machines/wgclient-ubuntu-bionic-x86_64/virtualbox/private_key \
    -o ControlMaster=auto \
    -o ControlPersist=60s")

function run_against_vbox_client() {
    ANSIBLE_HOST_KEY_CHECKING=false \
    ANSIBLE_SSH_ARGS="$ssh_options" \
    ansible-playbook --connection=ssh --timeout=30 --extra-vars=ansible_user='vagrant' \
        --limit="wgclient-ubuntu-bionic-x86_64" \
        --inventory-file=environments/dev/hosts \
        --vault-password-file=~/.ansible/vault-pass \
        -e "wg_server_endpoint=$server_hostname" \
        ansible/wireguard-client.yml
}

function run_against_mac_client() {
    ANSIBLE_SSH_PIPELINING=true \
    ansible-playbook \
        --limit="rust_slave-osx-mojave-x86_64" \
        --inventory-file=environments/dev/hosts \
        --vault-password-file=~/.ansible/vault-pass \
        -e "wg_server_endpoint=$server_hostname" \
        ansible/wireguard-client.yml
}

function run_against_server() {
    rm -rf ~/.ansible/tmp
    ansible-playbook --connection=ssh --timeout=30 --user='ubuntu' \
        --limit="wgserver" \
        --inventory-file=environments/dev \
        --vault-password-file=~/.ansible/vault-pass \
        -e "wg_run_on_host=True" \
        ansible/wireguard-server.yml
}

server_hostname=$(vagrant ssh-config jenkins_master-ubuntu-bionic-x86_64-aws | \
    grep "HostName" | awk '{ print $2 }')
run_against_server
[[ $mode == "vbox" ]] && run_against_vbox_client
[[ $mode == "mac" ]] && run_against_mac_client

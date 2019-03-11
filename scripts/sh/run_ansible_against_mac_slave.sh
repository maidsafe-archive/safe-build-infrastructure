#!/bin/bash

set -e

server_hostname=$(vagrant ssh-config jenkins_master-ubuntu-bionic-x86_64-aws | \
    grep "HostName" | awk '{ print $2 }')
ansible-playbook -i environments/dev/hosts \
    --limit=rust_slave-osx-mojave-x86_64 \
    --vault-password-file=~/.ansible/vault-pass \
    --private-key=~/.ssh/id_rsa \
    -e "wg_server_endpoint=$server_hostname" \
    ansible/osx-rust-slave.yml

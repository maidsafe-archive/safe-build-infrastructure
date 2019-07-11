#!/usr/bin/env bash

set -e

if [[ -d "/vagrant" ]]; then
    if [[ ! -d "/vagrant/ansible/roles/java" ]]; then
        sudo yum install -y git
        cd /vagrant/ansible/roles
        git clone https://github.com/geerlingguy/ansible-role-java java
    fi
else
    if [[ ! -d "ansible/roles/java" ]]; then
        git clone https://github.com/geerlingguy/ansible-role-java ansible/roles/java
    fi
fi

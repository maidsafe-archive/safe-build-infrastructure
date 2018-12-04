#!/usr/bin/env bash

if [[ ! -d "/vagrant/ansible/roles/java" ]]; then
    sudo yum install -y git
    cd /vagrant/ansible/roles
    git clone https://github.com/geerlingguy/ansible-role-java java
fi

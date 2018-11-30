#!/usr/bin/env bash

[[ -f "/etc/redhat-release" ]] && sudo yum install -y git
[[ -f "/etc/debian_version" ]] && sudo apt-get install -y git

if [[ ! -d "/vagrant/ansible/roles/java" ]]; then
    sudo yum install -y git
    cd /vagrant/ansible/roles
    git clone https://github.com/geerlingguy/ansible-role-java java
fi

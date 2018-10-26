#!/usr/bin/env bash

function install_pip() {
    curl "https://bootstrap.pypa.io/get-pip.py" -o get-pip.py
    python get-pip.py
}

function install_ansible() {
    pip install -U cffi
    pip install ansible
}

[[ -f "/etc/debian_version" ]] && apt-get update -y 
[[ -f "/etc/redhat-release" ]] && yum update -y
install_pip
install_ansible

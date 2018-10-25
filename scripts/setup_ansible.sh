#!/usr/bin/env bash

function install_pip() {
    curl "https://bootstrap.pypa.io/get-pip.py" -o get-pip.py
    python get-pip.py
}

function install_ansible() {
    yum install -y libffi-devel openssl-devel python-devel
    pip install -U cffi
    pip install ansible
}

yum update -y
install_pip
install_ansible

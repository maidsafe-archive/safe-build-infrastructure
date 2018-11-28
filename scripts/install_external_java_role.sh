#!/usr/bin/env bash

sudo yum install -y git
cd /vagrant/ansible/roles
git clone https://github.com/geerlingguy/ansible-role-java java

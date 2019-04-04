#!/usr/bin/env bash

# This script exists just because there are problems with the windows slave password
# variable if it has a dollar in it and you try to reference that in the Makefile.

EC2_INI_PATH=/etc/ansible/ec2.ini ansible-playbook -i environments/prod \
    --vault-password-file=~/.ansible/vault-pass \
    -e "cloud_environment=true" \
    -e "ansible_password=$JENKINS_WINDOWS_SLAVE_PASSWORD" \
    -e "jenkins_master_url=$JENKINS_MASTER_HOSTNAME" \
    ansible/win-jenkins-slave.yml

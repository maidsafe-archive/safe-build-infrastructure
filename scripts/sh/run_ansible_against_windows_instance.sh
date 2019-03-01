#!/bin/bash

set -e

instance_id=$(cat .aws_provision/instance_id)
password=$(cat .aws_provision/instance_password)

function run_ansible() {
    jenkins_master_url=$(vagrant ssh-config jenkins_master-centos-7.5-x86_64-aws | \
        grep "HostName" | awk '{ print $2 }')
    echo "Attempting Ansible run against instance... (can take 10+ seconds before output)"
    rm -rf ~/.ansible/tmp
    EC2_INI_PATH=/etc/ansible/ec2.ini ansible-playbook -i environments/dev \
        --vault-password-file=~/.ansible/vault-pass \
		--private-key=~/.ssh/jenkins_env_key \
        -e "cloud_environment=true" \
        -e "ansible_password=$password" \
        -e "jenkins_master_url=$jenkins_master_url" \
        ansible/jenkins-slave-windows.yml
}

function reboot_instance() {
    echo "Rebooting instance for necessary changes to take effect."
    echo "The Jenkins GUI will indicate when the machine becomes available again."
    aws ec2 reboot-instances --region eu-west-2 --instance-ids "$instance_id"
}

run_ansible
reboot_instance

echo "You can connect to Jenkins at http://$jenkins_master_url:8080/."

#!/usr/bin/env bash

set -e

function centos_setup_ansible_user() {
    adduser --password "" ansible
}

function debian_setup_ansible_user() {
    adduser --disabled-password --gecos "" ansible
}

touch /etc/reached
if [[ -f "/etc/redhat-release" ]]; then
    yum update -y
    centos_setup_ansible_user
fi
if [[ -f "/etc/debian_version" ]]; then
    apt-get update -y
    apt-get install -y python
    debian_setup_ansible_user
fi

mkdir /home/ansible/.ssh
chown ansible:ansible /home/ansible/.ssh
chmod 0700 /home/ansible/.ssh
cat > /home/ansible/.ssh/authorized_keys <<- EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxj450RtAtF+z3VFPUQiziVRNucPIerr7hrTp48EYh5geCEhQoSB68Mt8IDr8l9xCB5EtMPd/iPDpYCLAoELy+mcusOc6kIydkkLtDcOKeFBxOzyFcqRBUxGKyl3y4J/dWbBwl4OEQ0i7ylIXbvBlIv1ZJ4B5LhEcPDmiEuaHAn/8h42/SIyTYhxd3Y406/FtlzuhML+JlZbioixGpATwzHJrLUflJgSiczSlOC+U6wD2Nn1e+127UZCC006YWNO7tbO8glOmoNe4MMZSmoWaygtuTOWESOQkMnAUz92sH3kubmhzgoivJTEJTVLIGGnMFdvGpN0Q7GWqDbjPx6s8r
EOF
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 0600 /home/ansible/.ssh/authorized_keys
echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible

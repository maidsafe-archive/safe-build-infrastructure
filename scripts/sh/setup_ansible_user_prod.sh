#!/usr/bin/env bash

set -e

function centos_setup_ansible_user() {
    adduser --password "" ansible
}

function debian_setup_ansible_user() {
    adduser --disabled-password --gecos "" ansible
}

if [[ -f "/etc/redhat-release" ]]; then
    # Sometimes the yum update appears to fail and I think it might be due to connectivity.
    sleep 30
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
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCy2jDTSMksE7ZXbDMG/0RWi6jsKUSa5ui+hEzr65FiSUY93EoB/+bXyRnzSmUOp/p1tfbaw5G2KIEhKC5y1rP3FIaxm4k70tS4ZWE235W8ysW4W7MhaxLWtVrtn+ksjL8fa9YBtkxhtjcpnGYDA8OftR3HAFZKsEtGgJ+GCm5NYnIgkDl+NFBQ0oJADiae1j0AiuBPH2tZimYL6TG10CbJV+VsEgGd4a5yRwYX+6smiOMcozLmc6QfobohgVlVJveUnrspDZyBTKezaC42Rv9iZ6YsYDGx/WAkhNWJaH34qkeD/W03Z+g05hAyMDNgVtFnxljcghVEr9NKufCdKliZ
EOF
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 0600 /home/ansible/.ssh/authorized_keys
echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible

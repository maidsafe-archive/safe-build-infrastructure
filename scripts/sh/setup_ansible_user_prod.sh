#!/usr/bin/env bash

set -e

[[ -f "/etc/redhat-release" ]] && adduser --password "" ansible
[[ -f "/etc/debian_version" ]] && adduser --disabled-password --gecos "" ansible

mkdir /home/ansible/.ssh
chown ansible:ansible /home/ansible/.ssh
chmod 0700 /home/ansible/.ssh
cat > /home/ansible/.ssh/authorized_keys <<- EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCy2jDTSMksE7ZXbDMG/0RWi6jsKUSa5ui+hEzr65FiSUY93EoB/+bXyRnzSmUOp/p1tfbaw5G2KIEhKC5y1rP3FIaxm4k70tS4ZWE235W8ysW4W7MhaxLWtVrtn+ksjL8fa9YBtkxhtjcpnGYDA8OftR3HAFZKsEtGgJ+GCm5NYnIgkDl+NFBQ0oJADiae1j0AiuBPH2tZimYL6TG10CbJV+VsEgGd4a5yRwYX+6smiOMcozLmc6QfobohgVlVJveUnrspDZyBTKezaC42Rv9iZ6YsYDGx/WAkhNWJaH34qkeD/W03Z+g05hAyMDNgVtFnxljcghVEr9NKufCdKliZ
EOF
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 0600 /home/ansible/.ssh/authorized_keys
echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible

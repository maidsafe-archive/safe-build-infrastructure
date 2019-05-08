#!/usr/bin/env bash

set -e

[[ -f "/etc/redhat-release" ]] && adduser --password "" ansible
[[ -f "/etc/debian_version" ]] && adduser --disabled-password --gecos "" ansible

mkdir /home/ansible/.ssh
chown ansible:ansible /home/ansible/.ssh
chmod 0700 /home/ansible/.ssh
cat > /home/ansible/.ssh/authorized_keys <<- EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxj450RtAtF+z3VFPUQiziVRNucPIerr7hrTp48EYh5geCEhQoSB68Mt8IDr8l9xCB5EtMPd/iPDpYCLAoELy+mcusOc6kIydkkLtDcOKeFBxOzyFcqRBUxGKyl3y4J/dWbBwl4OEQ0i7ylIXbvBlIv1ZJ4B5LhEcPDmiEuaHAn/8h42/SIyTYhxd3Y406/FtlzuhML+JlZbioixGpATwzHJrLUflJgSiczSlOC+U6wD2Nn1e+127UZCC006YWNO7tbO8glOmoNe4MMZSmoWaygtuTOWESOQkMnAUz92sH3kubmhzgoivJTEJTVLIGGnMFdvGpN0Q7GWqDbjPx6s8r
EOF
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 0600 /home/ansible/.ssh/authorized_keys
echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible

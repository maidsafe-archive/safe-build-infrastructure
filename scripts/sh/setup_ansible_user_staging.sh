#!/usr/bin/env bash

set -e

[[ -f "/etc/redhat-release" ]] && adduser --password "" ansible
[[ -f "/etc/debian_version" ]] && adduser --disabled-password --gecos "" ansible

mkdir /home/ansible/.ssh
chown ansible:ansible /home/ansible/.ssh
chmod 0700 /home/ansible/.ssh
cat > /home/ansible/.ssh/authorized_keys <<- EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCwWGjEnhGRD3mY9UgoK1krHs8VZVu0TzfAgsTwT8EqBgeT5mPnLaMuGTP7Q2qsertIAM7+AlAYdA2a5qeP+HKkjA0nutFYxsxblg/zSubznlApstVjx/NN48eXE0xFdj4dfqYQf8YFxHHkoIIPPqmt00lBubLVnzHQc3Nm18oIWuX0nJBUD6Y5BBf1xEjoPkQostQAmneuoO7S6ojT7GFr1GDiNJGxhvAdFR7WW1OtwUkfWx/7mXVdryJ1wjsmr6qFwsXXv4HtmXVGvCrQV8grFUhxAAljHPijoqJoBb5Hatb5B8n9R8DMTQYJBrWVuLEd6gzWmSA9VfVsOTYAhLSb
EOF
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 0600 /home/ansible/.ssh/authorized_keys
echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible

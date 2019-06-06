#!/usr/bin/env bash

set -e

[[ -f "/etc/redhat-release" ]] && adduser --password "" ansible
[[ -f "/etc/debian_version" ]] && adduser --disabled-password --gecos "" ansible

mkdir /home/ansible/.ssh
chown ansible:ansible /home/ansible/.ssh
chmod 0700 /home/ansible/.ssh
cat > /home/ansible/.ssh/authorized_keys <<- EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDbyNTXKxEF7/bTbOA1tj1NB3Ducg9C+4VLyV0yj+NHFOOJ/Ff99a/rQoqSSkH5ltcdGig6wW3ZE96eNnEHXxUtECe4ySiwkni3lEod2x48iX00Tt+/OEgbOOKwUW8Bpj2EujUwhOXGji1e2AaUDE8Y2woOnffchVE7vY0Oxeh6KvTbBh+RFlIJ0eWBTpJGZyiK0kHrgV2DkIABeup6p5vrIoWmZA+oRY8EOO6xIeextchCzIE0hETMdSu1UdVcx8K+vR9OIWolDx5D7wpJ1I46ZJmSmp4V/lDx2MYEaol4f1sbpn/9KQ23RAm22R/z7FwmZJhAUfWRDjmH6n/5xUwx
EOF
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 0600 /home/ansible/.ssh/authorized_keys
echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible

#!/usr/bin/env bash

VBOX_VERSION=$(cat /home/vagrant/.vbox_version)

export KERN_DIR=/usr/src/kernels/$(uname -r)
yum install -y epel-release
yum install -y "kernel-devel-uname-r == $(uname -r)"
yum install -y bzip2 dkms gcc perl tar

mkdir /mnt/vbox_guest
mount -o loop "/home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso" /mnt/vbox_guest
/mnt/vbox_guest/VBoxLinuxAdditions.run
umount /mnt/vbox_guest
rm -rf /mnt/vbox_guest

rm -f "/home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso"

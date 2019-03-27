#!/usr/bin/env bash

set -e

declare -a local_vms=(\
    "wgclient-ubuntu-bionic-x86_64" \
    "jenkins_master-centos-7.6-x86_64" \
    "rust_slave-centos-7.6-x86_64" \
    "docker_slave-centos-7.6-x86_64" \
    "rust_slave-ubuntu-trusty-x86_64" \
    "base-windows-2012_r2-x86_64" \
    "rust_slave_git_bash-windows-2012_r2-x86_64" \
    "jenkins_rust_slave-windows-2016-x86_64" \
    "rust_slave_msys2-windows-2012_r2-x86_64" \
    "travis_rust_slave-windows-2016-x86_64")

for machine_name in "${local_vms[@]}"
do
    if vagrant status "$machine_name" | grep "The VM is running" ; then
        vagrant destroy -f "$machine_name"
    fi
done

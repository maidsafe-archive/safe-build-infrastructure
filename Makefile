SHELL:=/bin/bash
DOCKER_SLAVE_URL := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^docker_slave_host_url" | awk '{ print $$2 }')
DOCKER_SLAVE_IP_ADDRESS := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^docker_slave_ip_address" | awk '{ print $$2 }')
JENKINS_MASTER_URL := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^jenkins_master_host_url" | awk '{ print $$2 }')
JENKINS_MASTER_IP_ADDRESS := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^jenkins_master_ip_address" | awk '{ print $$2 }')
WINDOWS_RUST_SLAVE_URL := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^windows_rust_slave_slave_host_url" | awk '{ print $$2 }')
WINDOWS_RUST_SLAVE_IP_ADDRESS := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^windows_rust_slave_slave_ip_address" | awk '{ print $$2 }')

build-windows2012_r2-slave:
	if [ ! -d "packer_output" ]; then mkdir packer_output; fi
	if [ -f "packer_output/windows2012r2min-virtualbox.box" ]; then rm packer_output/windows2012r2min-virtualbox.box; fi
	packer validate templates/vbox-win2012r2.json
	packer build templates/vbox-win2012r2.json

build-windows2016-slave:
	if [ ! -d "packer_output" ]; then mkdir packer_output; fi
	if [ -f "packer_output/windows2016-virtualbox.box" ]; then rm packer_output/windows2016-virtualbox.box; fi
	packer validate templates/vbox-win2016.json
	packer build templates/vbox-win2016.json
	vagrant box remove windows2016
	vagrant box add packer_output/windows2016-virtualbox.box --name windows2016

jenkins_master-centos-7.5-x86_64: export JENKINS_MASTER_IP_ADDRESS := ${JENKINS_MASTER_IP_ADDRESS}
jenkins_master-centos-7.5-x86_64: export JENKINS_MASTER_URL := ${JENKINS_MASTER_URL}
jenkins_master-centos-7.5-x86_64:
	vagrant up jenkins_master-centos-7.5-x86_64 --provision

rust_slave-centos-7.5-x86_64:
	vagrant up rust_slave-centos-7.5-x86_64 --provision

rust_slave-ubuntu-trusty-x86_64:
	vagrant up rust_slave-ubuntu-trusty-x86_64 --provision

docker_slave-centos-7.5-x86_64: export DOCKER_SLAVE_IP_ADDRESS := ${DOCKER_SLAVE_IP_ADDRESS}
docker_slave-centos-7.5-x86_64: export DOCKER_SLAVE_URL := ${DOCKER_SLAVE_URL}
docker_slave-centos-7.5-x86_64:
	vagrant up docker_slave-centos-7.5-x86_64 --provision

jenkins-environment: export DOCKER_SLAVE_IP_ADDRESS := ${DOCKER_SLAVE_IP_ADDRESS}
jenkins-environment: export DOCKER_SLAVE_URL := ${DOCKER_SLAVE_URL}
jenkins-environment: export JENKINS_MASTER_IP_ADDRESS := ${JENKINS_MASTER_IP_ADDRESS}
jenkins-environment: export JENKINS_MASTER_URL := ${JENKINS_MASTER_URL}
jenkins-environment: docker_slave-centos-7.5-x86_64 jenkins_master-centos-7.5-x86_64

base-windows-2012_r2-x86_64:
	vagrant up base-windows-2012_r2-x86_64 --provision

rust_slave_git_bash-windows-2012_r2-x86_64:
	vagrant up rust_slave_git_bash-windows-2012_r2-x86_64 --provision

rust_slave_msys2-windows-2012_r2-x86_64:
	vagrant up rust_slave_msys2-windows-2012_r2-x86_64 --provision

rust_travis_slave-windows-2016-x86_64: export WINDOWS_RUST_SLAVE_IP_ADDRESS := ${WINDOWS_RUST_SLAVE_IP_ADDRESS}
rust_travis_slave-windows-2016-x86_64: export WINDOWS_RUST_SLAVE_URL := ${WINDOWS_RUST_SLAVE_URL}
rust_travis_slave-windows-2016-x86_64:
	vagrant up rust_travis_slave-windows-2016-x86_64 --provision

clean:
	vagrant destroy -f

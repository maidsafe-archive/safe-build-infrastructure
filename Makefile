SHELL:=/bin/bash
DOCKER_SLAVE_URL := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^docker_slave_host_url" | awk '{ print $$2 }')
DOCKER_SLAVE_IP_ADDRESS := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^docker_slave_ip_address" | awk '{ print $$2 }')
JENKINS_MASTER_URL := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^jenkins_master_host_url" | awk '{ print $$2 }')
JENKINS_MASTER_IP_ADDRESS := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^jenkins_master_ip_address" | awk '{ print $$2 }')
WINDOWS_RUST_SLAVE_URL := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^windows_rust_slave_host_url" | awk '{ print $$2 }')
WINDOWS_RUST_SLAVE_IP_ADDRESS := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^windows_rust_slave_ip_address" | awk '{ print $$2 }')

build-base-windows-2012_r2-box:
	if [ ! -d "packer_output" ]; then mkdir packer_output; fi
	if [ -f "packer_output/base-windows-2012_r2-x86_64.box" ]; then rm packer_output/base-windows-2012_r2-x86_64.box; fi
	packer validate templates/base-windows-2012_r2-virtualbox-x86_64.json
	packer build templates/base-windows-2012_r2-virtualbox-x86_64.json

build-base-windows-2016-box:
	if [ ! -d "packer_output" ]; then mkdir packer_output; fi
	if [ -f "packer_output/base-windows-2016-virtualbox-x86_64.box" ]; then rm packer_output/base-windows-2016-virtualbox-x86_64.box; fi
	packer validate templates/base-windows-2016-virtualbox-x86_64.json
	packer build templates/base-windows-2016-virtualbox-x86_64.json

build-travis_slave-windows-2016-box:
	if [ ! -d "packer_output" ]; then mkdir packer_output; fi
	if [ -f "packer_output/travis_slave-windows-2016-virtualbox-x86_64.box" ]; then rm packer_output/travis_slave-windows-2016-virtualbox-x86_64.box; fi
	packer validate templates/travis_slave-windows-2016-virtualbox-x86_64.json
	packer build templates/travis_slave-windows-2016-virtualbox-x86_64.json

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
jenkins-environment: \
	docker_slave-centos-7.5-x86_64 \
	jenkins_master-centos-7.5-x86_64 \
	travis_rust_slave-windows-2016-x86_64
	vagrant reload travis_rust_slave-windows-2016-x86_64

jenkins-environment-aws:
	# For some reason Ansible doesn't work with the traditional way of exporting environment
	# variables as part of the target (see the 'travis_rust_slave-windows-2016-x86_64' target).
	# Also, the ~/.ansible/tmp directory caches the results from the dynamic inventory provider
	# and this sometimes prevent hosts from being matched correctly, hence why it gets cleared.
	#
	# The Windows instance is fired up before the Jenkins master, but it's not provisioned with
	# Ansible until after the Jenkins master. The Jenkins master needs the Windows host to appear
	# in the inventory because it uses that to populate the Jenkins configuration file. However,
	# the Ansible run for the Windows slave can only happen *after* the Jenkins master exists,
	# because you need to specify the URL of the Jenkins master.
	./scripts/sh/create_dev_security_group.sh
	vagrant up docker_slave_01-centos-7.5-x86_64-aws --provider=aws
	vagrant up docker_slave_02-centos-7.5-x86_64-aws --provider=aws
	./scripts/sh/run_windows_instance.sh
	rm -rf ~/.ansible/tmp
	EC2_INI_PATH=/etc/ansible/ec2.ini ansible-playbook -i environments/dev \
		--vault-password-file=~/.ansible/vault-pass \
		-e "cloud_environment=true" \
		-u centos ansible/docker-slave.yml
	vagrant up jenkins_master-centos-7.5-x86_64-aws --provider=aws
	rm -rf ~/.ansible/tmp
	EC2_INI_PATH=/etc/ansible/ec2.ini ansible-playbook -i environments/dev \
		--vault-password-file=~/.ansible/vault-pass \
		-e "cloud_environment=true" \
		-u centos ansible/jenkins-master.yml
	./scripts/sh/run_ansible_against_windows_instance.sh

base-windows-2012_r2-x86_64:
	vagrant up base-windows-2012_r2-x86_64 --provision

rust_slave_git_bash-windows-2012_r2-x86_64:
	vagrant up rust_slave_git_bash-windows-2012_r2-x86_64 --provision

rust_slave_msys2-windows-2012_r2-x86_64:
	vagrant up rust_slave_msys2-windows-2012_r2-x86_64 --provision

travis_rust_slave-windows-2016-x86_64: export OBJC_DISABLE_INITIALIZE_FORK_SAFETY := YES
travis_rust_slave-windows-2016-x86_64: export JENKINS_MASTER_IP_ADDRESS := ${JENKINS_MASTER_IP_ADDRESS}
travis_rust_slave-windows-2016-x86_64: export JENKINS_MASTER_URL := ${JENKINS_MASTER_URL}
travis_rust_slave-windows-2016-x86_64: export WINDOWS_RUST_SLAVE_IP_ADDRESS := ${WINDOWS_RUST_SLAVE_IP_ADDRESS}
travis_rust_slave-windows-2016-x86_64: export WINDOWS_RUST_SLAVE_URL := ${WINDOWS_RUST_SLAVE_URL}
travis_rust_slave-windows-2016-x86_64:
	vagrant up travis_rust_slave-windows-2016-x86_64 --provision

provision-rust_slave-osx-mojave-x86_64:
	# Pipelining must be enabled to get around a problem with permissions and temporary files on OSX:
	# https://docs.ansible.com/ansible/latest/user_guide/become.html#becoming-an-unprivileged-user
	ANSIBLE_PIPELINING=True ansible-playbook -i environments/vagrant/hosts ansible/osx-rust-slave.yml

clean-rust_slave-osx-mojave-x86_64:
	ANSIBLE_PIPELINING=True ansible-playbook -i environments/vagrant/hosts ansible/osx-teardown.yml

clean:
	vagrant destroy -f docker_slave-centos-7.5-x86_64
	vagrant destroy -f jenkins_master-centos-7.5-x86_64
	vagrant destroy -f travis_rust_slave-windows-2016-x86_64

clean-aws:
	aws ec2 --region eu-west-2 terminate-instances --instance-ids $$(cat .aws_provision/instance_id)
	vagrant destroy -f docker_slave_01-centos-7.5-x86_64-aws
	vagrant destroy -f docker_slave_02-centos-7.5-x86_64-aws
	vagrant destroy -f jenkins_master-centos-7.5-x86_64-aws
	aws ec2 --region eu-west-2 delete-security-group --group-id $$(cat .aws_provision/jenkins_security_group_id)
	aws ec2 --region eu-west-2 delete-security-group --group-id $$(cat .aws_provision/windows_slaves_security_group_id)
	rm -rf .aws_provision

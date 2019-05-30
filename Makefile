SHELL:=/bin/bash
DOCKER_SLAVE_URL := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^docker_slave_host_url" | awk '{ print $$2 }')
DOCKER_SLAVE_IP_ADDRESS := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^docker_slave_ip_address" | awk '{ print $$2 }')
JENKINS_MASTER_URL := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^jenkins_master_host_url" | awk '{ print $$2 }')
JENKINS_MASTER_IP_ADDRESS := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^jenkins_master_ip_address" | awk '{ print $$2 }')
WINDOWS_RUST_SLAVE_URL := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^windows_rust_slave_host_url" | awk '{ print $$2 }')
WINDOWS_RUST_SLAVE_IP_ADDRESS := $(shell cat environments/vagrant/group_vars/all/vars.yml | grep "^windows_rust_slave_ip_address" | awk '{ print $$2 }')

box-base-windows-2012_r2-vbox:
	if [ ! -d "packer_output" ]; then mkdir packer_output; fi
	if [ -f "packer_output/base-windows-2012_r2-x86_64.box" ]; then rm packer_output/base-windows-2012_r2-x86_64.box; fi
	packer validate templates/base-windows-2012_r2-virtualbox-x86_64.json
	packer build templates/base-windows-2012_r2-virtualbox-x86_64.json

box-base-windows-2016-vbox:
	if [ ! -d "packer_output" ]; then mkdir packer_output; fi
	if [ -f "packer_output/base-windows-2016-virtualbox-x86_64.box" ]; then rm packer_output/base-windows-2016-virtualbox-x86_64.box; fi
	packer validate templates/base-windows-2016-virtualbox-x86_64.json
	packer build templates/base-windows-2016-virtualbox-x86_64.json

box-travis_slave-windows-2016-vbox:
	if [ ! -d "packer_output" ]; then mkdir packer_output; fi
	if [ -f "packer_output/travis_slave-windows-2016-virtualbox-x86_64.box" ]; then rm packer_output/travis_slave-windows-2016-virtualbox-x86_64.box; fi
	packer validate templates/travis_slave-windows-2016-virtualbox-x86_64.json
	packer build -only=amazon-ebs templates/travis_slave-windows-2016-virtualbox-x86_64.json

box-docker_slave-ubuntu-bionic-x86_64-aws:
	rm -rf ~/.ansible/tmp
	packer validate templates/docker_slave-ubuntu-bionic-x86_64.json
	EC2_INI_PATH=environments/prod/ec2.ini \
		packer build \
		-only=amazon-ebs \
		-var='cloud_environment=prod' \
		templates/docker_slave-ubuntu-bionic-x86_64.json

box-rust_slave-windows-2016-x86_64-aws:
ifndef WINDOWS_ANSIBLE_USER_PASSWORD
	@echo "To build this box, a password must be set for the Ansible user."
	@echo "Please set WINDOWS_ANSIBLE_USER_PASSWORD with a secure password."
	@exit 1
endif
	rm -rf ~/.ansible/tmp
	packer validate templates/rust_slave-windows-2016-x86_64.json
	EC2_INI_PATH=environments/prod/ec2.ini PACKER_LOG=1 \
		packer build \
		-only=amazon-ebs \
		templates/rust_slave-windows-2016-x86_64.json

box-docker_slave-ubuntu-bionic-x86_64-vbox:
	if [ ! -f "iso/ubuntu-18.04.1-server-amd64.iso" ]; then \
		cd iso; \
		curl -O http://old-releases.ubuntu.com/releases/bionic/ubuntu-18.04.1-server-amd64.iso; \
		cd ..; \
	fi
	rm -rf output-virtualbox-iso
	if [ ! -d "packer_output" ]; then mkdir packer_output; fi
	if [ -f "packer_output/docker_slave-ubuntu-bionic-x86_64.box" ]; then \
		rm packer_output/docker_slave-ubuntu-bionic-x86_64.box; \
	fi
	packer validate templates/docker_slave-ubuntu-bionic-x86_64.json
	packer build \
		-only=virtualbox-iso \
		-var 'ansible_inventory_directory=environments/vagrant' \
		-var 'cloud_environment=vagrant' \
		templates/docker_slave-ubuntu-bionic-x86_64.json
	vagrant box add --name "maidsafe/docker_slave-ubuntu-bionic-x86_64" \
		packer_output/docker_slave-ubuntu-bionic-x86_64.box --force
	aws s3 cp \
		packer_output/docker_slave-ubuntu-bionic-x86_64.box \
		s3://safe-vagrant-boxes/docker_slave-ubuntu-bionic-x86_64.box

box-jenkins_master-centos-7.6-x86_64-vbox:
	rm -rf output-virtualbox-iso
	if [ ! -d "packer_output" ]; then mkdir packer_output; fi
	if [ -f "packer_output/jenkins_master-centos-7.6-x86_64.box" ]; then \
		rm packer_output/jenkins_master-centos-7.6-x86_64.box; \
	fi
	packer validate templates/jenkins_master-centos-7.6-x86_64.json
	packer build -only=virtualbox-iso templates/jenkins_master-centos-7.6-x86_64.json
	vagrant box add --name "maidsafe/jenkins_master-centos-7.6-x86_64" \
		packer_output/jenkins_master-centos-7.6-x86_64.box --force
	aws s3 cp \
		packer_output/jenkins_master-centos-7.6-x86_64.box \
		s3://safe-vagrant-boxes/jenkins_master-centos-7.6-x86_64.box

vm-jenkins_master-centos-7.6-x86_64-vbox: export JENKINS_MASTER_IP_ADDRESS := ${JENKINS_MASTER_IP_ADDRESS}
vm-jenkins_master-centos-7.6-x86_64-vbox: export JENKINS_MASTER_URL := ${JENKINS_MASTER_URL}
vm-jenkins_master-centos-7.6-x86_64-vbox:
	vagrant up jenkins_master-centos-7.6-x86_64 --provision

vm-rust_slave-centos-7.6-x86_64-vbox:
	vagrant up rust_slave-centos-7.6-x86_64 --provision

vm-rust_slave-ubuntu-trusty-x86_64-vbox:
	vagrant up rust_slave-ubuntu-trusty-x86_64 --provision

vm-docker_slave-centos-7.6-x86_64-vbox: export DOCKER_SLAVE_IP_ADDRESS := ${DOCKER_SLAVE_IP_ADDRESS}
vm-docker_slave-centos-7.6-x86_64-vbox: export DOCKER_SLAVE_URL := ${DOCKER_SLAVE_URL}
vm-docker_slave-centos-7.6-x86_64-vbox:
	vagrant up docker_slave-centos-7.6-x86_64 --provision

vm-docker_slave_quick-centos-7.6-x86_64-vbox: export DOCKER_SLAVE_IP_ADDRESS := ${DOCKER_SLAVE_IP_ADDRESS}
vm-docker_slave_quick-centos-7.6-x86_64-vbox: export DOCKER_SLAVE_URL := ${DOCKER_SLAVE_URL}
vm-docker_slave_quick-centos-7.6-x86_64-vbox:
	vagrant up docker_slave_quick-centos-7.6-x86_64

vm-base-windows-2012_r2-x86_64-vbox:
	vagrant up base-windows-2012_r2-x86_64 --provision

vm-rust_slave_git_bash-windows-2012_r2-x86_64-vbox:
	vagrant up rust_slave_git_bash-windows-2012_r2-x86_64 --provision

vm-rust_slave_msys2-windows-2012_r2-x86_64-vbox:
	vagrant up rust_slave_msys2-windows-2012_r2-x86_64 --provision

vm-jenkins_rust_slave-windows-2016-x86_64-vbox: export OBJC_DISABLE_INITIALIZE_FORK_SAFETY := YES
vm-jenkins_rust_slave-windows-2016-x86_64-vbox: export JENKINS_MASTER_IP_ADDRESS := ${JENKINS_MASTER_IP_ADDRESS}
vm-jenkins_rust_slave-windows-2016-x86_64-vbox: export JENKINS_MASTER_URL := ${JENKINS_MASTER_URL}
vm-jenkins_rust_slave-windows-2016-x86_64-vbox: export WINDOWS_RUST_SLAVE_IP_ADDRESS := ${WINDOWS_RUST_SLAVE_IP_ADDRESS}
vm-jenkins_rust_slave-windows-2016-x86_64-vbox: export WINDOWS_RUST_SLAVE_URL := ${WINDOWS_RUST_SLAVE_URL}
vm-jenkins_rust_slave-windows-2016-x86_64-vbox:
	vagrant up jenkins_rust_slave-windows-2016-x86_64 --provision

vm-travis_rust_slave-windows-2016-x86_64-vbox:
	vagrant up travis_rust_slave-windows-2016-x86_64 --provision

vm-kali_linux-v2019.2.0-x86_64-vbox:
	vagrant up kali-linux

vm-pen_test_desktop-lubuntu-18.04-x86_64-vbox:
	vagrant up lubuntu-desktop
	vagrant reload lubuntu-desktop

vm-docker_slave-centos-7.6-x86_64-aws:
	vagrant up docker_slave-centos-7.6-x86_64-aws --provision --provider=aws
	EC2_INI_PATH=environments/dev/ec2.ini ansible-playbook -i environments/dev \
		--vault-password-file=~/.ansible/vault-pass \
		--private-key=~/.ssh/vagrant \
		--limit=docker_slave_001 \
		-e "cloud_environment=dev" \
		-u centos ansible/docker-slave.yml

env-jenkins-dev-vbox: export DOCKER_SLAVE_IP_ADDRESS := ${DOCKER_SLAVE_IP_ADDRESS}
env-jenkins-dev-vbox: export DOCKER_SLAVE_URL := ${DOCKER_SLAVE_URL}
env-jenkins-dev-vbox: export JENKINS_MASTER_IP_ADDRESS := ${JENKINS_MASTER_IP_ADDRESS}
env-jenkins-dev-vbox: export JENKINS_MASTER_URL := ${JENKINS_MASTER_URL}
env-jenkins-dev-vbox: \
	vm-docker_slave-centos-7.6-x86_64-vbox \
	vm-jenkins_master-centos-7.6-x86_64-vbox \
	vm-jenkins_rust_slave-windows-2016-x86_64-vbox
	vagrant reload jenkins_rust_slave-windows-2016-x86_64

env-jenkins-dev-aws:
	./scripts/sh/install_external_java_role.sh
	cd terraform/dev && terraform init && terraform apply -auto-approve
	cd ../..
	./scripts/sh/update_machine.sh "docker_slave_001" "dev"
	./scripts/sh/update_machine.sh "docker_slave_002" "dev"
	@echo "Attempting Ansible run against Docker slaves...(can be 10+ seconds before output)"
	rm -rf ~/.ansible/tmp
	EC2_INI_PATH=environments/dev/ec2.ini ansible-playbook -i environments/dev \
		--vault-password-file=~/.ansible/vault-pass \
		--private-key=~/.ssh/ansible_dev \
		-e "cloud_environment=dev" \
		-u ansible ansible/docker-slave.yml
	./scripts/sh/update_machine.sh "jenkins_master" "dev"
	./scripts/sh/run_ansible_against_jenkins_master.sh "dev"
	python ./scripts/py/run_ansible_against_windows_slaves.py "dev"

.ONESHELL:
env-jenkins-prod-aws:
ifndef AWS_ACCESS_KEY_ID
	@echo "Your AWS access key ID must be set."
	@exit 1
endif
ifndef AWS_SECRET_ACCESS_KEY
	@echo "Your AWS secret access key must be set."
	@exit 1
endif
ifeq ($(DEBUG_JENKINS_ENV),true)
	cd terraform/prod && terraform init && terraform apply -auto-approve -var-file=debug.tfvars
else
	cd terraform/prod && terraform init && terraform apply -auto-approve
endif
	cd ../..
	./scripts/sh/update_machine.sh "ansible_bastion" "prod"
	rm -rf ~/.ansible/tmp
	echo "Attempting Ansible run against Bastion... (can be 10+ seconds before output)"
	EC2_INI_PATH=environments/prod/ec2-host.ini ansible-playbook -i environments/prod \
		--vault-password-file=~/.ansible/vault-pass \
		--private-key=~/.ssh/ansible_prod \
		-e "cloud_environment=prod" \
		-e "aws_access_key_id=${AWS_ACCESS_KEY_ID}" \
		-e "aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}" \
		-e "ansible_vault_password=$$(cat ~/.ansible/vault-pass)" \
		-e "safe_build_infrastructure_repo_owner=jacderida" \
		-e "safe_build_infrastructure_repo_branch=additional_windows_slave" \
		-u ansible ansible/ansible-provisioner.yml
	./scripts/sh/prepare_bastion.sh

provision-jenkins-prod-aws:
	./scripts/sh/install_external_java_role.sh
	./scripts/sh/update_machine.sh "jenkins_master" "prod"
	./scripts/sh/update_machine.sh "haproxy" "prod"
	./scripts/sh/run_ansible_against_haproxy.sh "prod" "ec2-bastion.ini"
	./scripts/sh/run_ansible_against_jenkins_master.sh "prod" "ec2-bastion.ini"
	rm -rf ~/.ansible/tmp
	echo "Running Ansible against proxy instance for SSL configuration... (can be 10+ seconds before output)"
	EC2_INI_PATH="environments/prod/ec2-bastion.ini" \
		ansible-playbook -i "environments/prod" \
		--private-key="~/.ssh/ansible_prod" \
		--limit=haproxy \
		--vault-password-file=~/.ansible/vault-pass \
		-e "cloud_environment=prod" \
		-u ansible ansible/haproxy-ssl-config.yml
	python ./scripts/py/run_ansible_against_windows_slaves.py "prod" "ec2-bastion.ini"

provision-rust_slave-macos-mojave-x86_64-vagrant-vbox:
	ANSIBLE_SSH_PIPELINING=true ansible-playbook -i environments/vagrant/hosts \
		--limit=macos_rust_slave \
		--vault-password-file=~/.ansible/vault-pass \
		--private-key=~/.ssh/id_rsa \
		-e "cloud_environment=none" \
		ansible/osx-rust-slave.yml

provision-rust_slave-macos-mojave-x86_64-prod-aws:
	./scripts/sh/run_ansible_against_mac_slave.sh

clean-rust_slave-macos-mojave-x86_64:
	ANSIBLE_PIPELINING=True ansible-playbook -i environments/vagrant/hosts ansible/osx-teardown.yml

clean-vbox:
	./scripts/sh/destroy_local_vms.sh

clean-jenkins-dev-aws:
	cd terraform/dev && terraform destroy

clean-jenkins-prod-aws:
	cd terraform/prod && terraform destroy

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

box-docker_slave-centos-7.6-x86_64-aws:
	rm -rf ~/.ansible/tmp
	packer validate templates/docker_slave-centos-7.6-x86_64.json
	EC2_INI_PATH=environments/dev/ec2.ini \
		packer build \
		-only=amazon-ebs \
		-var='cloud_environment=prod' \
		templates/docker_slave-centos-7.6-x86_64.json

box-docker_slave-centos-7.6-x86_64-vbox:
	rm -rf output-virtualbox-iso
	if [ ! -d "packer_output" ]; then mkdir packer_output; fi
	if [ -f "packer_output/docker_slave-centos-7.6-x86_64.box" ]; then \
		rm packer_output/docker_slave-centos-7.6-x86_64.box; \
	fi
	packer validate templates/docker_slave-centos-7.6-x86_64.json
	packer build -only=virtualbox-iso templates/docker_slave-centos-7.6-x86_64.json
	vagrant box add --name "maidsafe/docker_slave-centos-7.6-x86_64" \
		packer_output/docker_slave-centos-7.6-x86_64.box --force
	aws s3 cp \
		packer_output/docker_slave-centos-7.6-x86_64.box \
		s3://safe-vagrant-boxes/docker_slave-centos-7.6-x86_64.box

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
	@echo "Sleep for 3 minutes to allow SSH to become available and yum updates on Linux instances..."
	@sleep 180
	@echo "Attempting Ansible run against Docker slaves...(can be 10+ seconds before output)"
	rm -rf ~/.ansible/tmp
	EC2_INI_PATH=environments/dev/ec2.ini ansible-playbook -i environments/dev \
		--vault-password-file=~/.ansible/vault-pass \
		--private-key=~/.ssh/jenkins_env_key \
		-e "cloud_environment=dev" \
		-u centos ansible/docker-slave.yml
	rm -rf ~/.ansible/tmp
	./scripts/sh/run_ansible_against_jenkins_master.sh "dev"
	./scripts/sh/run_ansible_against_windows_instance.sh "dev"

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
	rm -rf ~/.ansible/tmp
	echo "Sleep for 2 minutes to allow yum update to complete"
	sleep 120
	EC2_INI_PATH=environments/prod/ec2-host.ini ansible-playbook -i environments/prod \
		--vault-password-file=~/.ansible/vault-pass \
		--private-key=~/.ssh/ansible \
		-e "cloud_environment=prod" \
		-e "aws_access_key_id=${AWS_ACCESS_KEY_ID}" \
		-e "aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}" \
		-e "ansible_vault_password=$$(cat ~/.ansible/vault-pass)" \
		-e "safe_build_infrastructure_repo_owner=jacderida" \
		-e "safe_build_infrastructure_repo_branch=github_auth" \
		-u ansible ansible/ansible-provisioner.yml
	./scripts/sh/prepare_bastion.sh

provision-jenkins-prod-aws:
	./scripts/sh/install_external_java_role.sh
	./scripts/sh/run_ansible_against_jenkins_master.sh "prod" "ec2-bastion.ini"
	./scripts/sh/run_ansible_against_windows_instance.sh "prod" "ec2-bastion.ini"

provision-rust_slave-macos-mojave-x86_64:
	./scripts/sh/run_ansible_against_mac_slave.sh

clean-rust_slave-macos-mojave-x86_64:
	ANSIBLE_PIPELINING=True ansible-playbook -i environments/vagrant/hosts ansible/osx-teardown.yml

clean-vbox:
	./scripts/sh/destroy_local_vms.sh

clean-jenkins-dev-aws:
	cd terraform/dev && terraform destroy

clean-jenkins-prod-aws:
	cd terraform/prod && terraform destroy

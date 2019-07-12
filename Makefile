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
	./scripts/sh/install_external_java_role.sh
	packer validate templates/docker_slave-ubuntu-bionic-x86_64.json
	EC2_INI_PATH=environments/prod/ec2.ini \
		packer build \
		-only=amazon-ebs \
		-var='cloud_environment=prod' \
		-var "commit_hash=$$(git rev-parse --short HEAD)" \
		-var "ansible_vault_password=$$(cat ~/.ansible/vault-pass)" \
		templates/docker_slave-ubuntu-bionic-x86_64.json

box-util_slave-ubuntu-bionic-x86_64-aws:
	rm -rf ~/.ansible/tmp
	./scripts/sh/install_external_java_role.sh
	packer validate templates/util_slave-ubuntu-bionic-x86_64.json
	EC2_INI_PATH=environments/prod/ec2.ini \
		packer build \
		-only=amazon-ebs \
		-var='cloud_environment=prod' \
		-var "commit_hash=$$(git rev-parse --short HEAD)" \
		templates/util_slave-ubuntu-bionic-x86_64.json

box-rust_slave-windows-2016-x86_64-aws:
	packer validate templates/rust_slave-windows-2016-x86_64.json
	packer build \
		-var "commit_hash=$$(git rev-parse --short HEAD)" \
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

vm-util_slave-ubuntu-bionic-x86_64-aws:
	vagrant up util_slave-ubuntu-bionic-x86_64-aws --provision --provider=aws
	vagrant ssh util_slave-ubuntu-bionic-x86_64-aws -c "sudo apt-get install -y python"
	echo "Running Ansible... (can be 10+ seconds before output)"
	EC2_INI_PATH=environments/dev/ec2.ini ansible-playbook -i environments/dev \
		--vault-password-file=~/.ansible/vault-pass \
		--private-key=~/.ssh/vagrant \
		--limit=util_slave \
		-e "cloud_environment=dev" \
		-e "build_user=util" \
		-e "provisioning_user=util" \
		-e "ansible_vault_password=$$(cat ~/.ansible/vault-pass)" \
		-u ubuntu ansible/util-slave.yml

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
	./scripts/sh/reboot_all_instances.sh "dev"

.ONESHELL:
env-jenkins-qa-aws:
ifndef SAFE_BUILD_INFRA_REPO_OWNER
	@echo "The SAFE_BUILD_INFRA_REPO_OWNER environment variable must be set."
	@exit 1
endif
ifndef WINDOWS_QA_ANSIBLE_USER_PASSWORD
	@echo "The WINDOWS_QA_ANSIBLE_USER_PASSWORD environment variable must be set."
	@exit 1
endif
ifndef AWS_ACCESS_KEY_ID
	@echo "Your AWS access key ID must be set."
	@exit 1
endif
ifndef AWS_SECRET_ACCESS_KEY
	@echo "Your AWS secret access key must be set."
	@exit 1
endif
ifeq ($(DEBUG_JENKINS_ENV),true)
	cd terraform/qa && terraform init && terraform apply -auto-approve -var='windows_bastion_count=1'
else
	cd terraform/qa && terraform init && terraform apply -auto-approve
endif
	cd ../..
	./scripts/sh/update_machine.sh "ansible_bastion" "qa"
	rm -rf ~/.ansible/tmp
	echo "Attempting Ansible run against Bastion... (can be 10+ seconds before output)"
	EC2_INI_PATH=environments/qa/ec2-host.ini ansible-playbook -i environments/qa \
		--vault-password-file=~/.ansible/vault-pass \
		--private-key=~/.ssh/ansible_qa \
		-e "cloud_environment=qa" \
		-e "aws_access_key_id=${AWS_ACCESS_KEY_ID}" \
		-e "aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}" \
		-e "ansible_vault_password=$$(cat ~/.ansible/vault-pass)" \
		-e "safe_build_infrastructure_repo_owner=${SAFE_BUILD_INFRA_REPO_OWNER}" \
		-e "safe_build_infrastructure_repo_branch=$$(git branch | grep \* | cut -d ' ' -f2)" \
		-u ansible ansible/ansible-provisioner.yml
	./scripts/sh/prepare_bastion.sh "qa"

.ONESHELL:
env-jenkins-staging-aws:
ifndef SAFE_BUILD_INFRA_REPO_OWNER
	@echo "The SAFE_BUILD_INFRA_REPO_OWNER environment variable must be set."
	@exit 1
endif
ifndef WINDOWS_STAGING_ANSIBLE_USER_PASSWORD
	@echo "The WINDOWS_STAGING_ANSIBLE_USER_PASSWORD environment variable must be set."
	@exit 1
endif
ifndef AWS_ACCESS_KEY_ID
	@echo "Your AWS access key ID must be set."
	@exit 1
endif
ifndef AWS_SECRET_ACCESS_KEY
	@echo "Your AWS secret access key must be set."
	@exit 1
endif
ifeq ($(DEBUG_JENKINS_ENV),true)
	cd terraform/staging && terraform init && terraform apply -auto-approve -var='windows_bastion_count=1'
else
	cd terraform/staging && terraform init && terraform apply -auto-approve
endif
	cd ../..
	./scripts/sh/update_machine.sh "ansible_bastion" "staging"
	rm -rf ~/.ansible/tmp
	echo "Attempting Ansible run against Bastion... (can be 10+ seconds before output)"
	EC2_INI_PATH=environments/staging/ec2-host.ini ansible-playbook -i environments/staging \
		--vault-password-file=~/.ansible/vault-pass \
		--private-key=~/.ssh/ansible_staging \
		-e "cloud_environment=staging" \
		-e "aws_access_key_id=${AWS_ACCESS_KEY_ID}" \
		-e "aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}" \
		-e "ansible_vault_password=$$(cat ~/.ansible/vault-pass)" \
		-e "safe_build_infrastructure_repo_owner=${SAFE_BUILD_INFRA_REPO_OWNER}" \
		-e "safe_build_infrastructure_repo_branch=$$(git branch | grep \* | cut -d ' ' -f2)" \
		-u ansible ansible/ansible-provisioner.yml
	./scripts/sh/prepare_bastion.sh "staging"

.ONESHELL:
env-jenkins-prod-aws:
ifndef WINDOWS_PROD_ANSIBLE_USER_PASSWORD
	@echo "The WINDOWS_PROD_ANSIBLE_USER_PASSWORD environment variable must be set."
	@exit 1
endif
ifndef AWS_ACCESS_KEY_ID
	@echo "Your AWS access key ID must be set."
	@exit 1
endif
ifndef AWS_SECRET_ACCESS_KEY
	@echo "Your AWS secret access key must be set."
	@exit 1
endif
ifeq ($(DEBUG_JENKINS_ENV),true)
	cd terraform/prod && terraform init && terraform apply -auto-approve -var='windows_bastion_count=1'
else
	cd terraform/prod && terraform init && terraform apply -auto-approve
endif
	cd ../..
	./scripts/sh/update_machine.sh "ansible_bastion" "prod"
	# Note: the prod environment is now live, so from now on, please *DO NOT* change
	# the safe_build_infrastructure_repo_owner and safe_build_infrastructure_repo_branch variables
	# in this target. They are still OK to change for staging or QA.
	rm -rf ~/.ansible/tmp
	echo "Attempting Ansible run against Bastion... (can be 10+ seconds before output)"
	EC2_INI_PATH=environments/prod/ec2-host.ini ansible-playbook -i environments/prod \
		--vault-password-file=~/.ansible/vault-pass \
		--private-key=~/.ssh/ansible_prod \
		-e "cloud_environment=prod" \
		-e "aws_access_key_id=${AWS_ACCESS_KEY_ID}" \
		-e "aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}" \
		-e "ansible_vault_password=$$(cat ~/.ansible/vault-pass)" \
		-e "safe_build_infrastructure_repo_owner=maidsafe" \
		-e "safe_build_infrastructure_repo_branch=master" \
		-u ansible ansible/ansible-provisioner.yml
	./scripts/sh/prepare_bastion.sh "prod"

provision-jenkins-qa-aws-initial:
	./scripts/sh/install_external_java_role.sh
	./scripts/sh/update_machine.sh "jenkins_master" "qa"
	./scripts/sh/update_machine.sh "haproxy" "qa"
	./scripts/sh/run_ansible_against_haproxy.sh "qa" "initial" "ec2-bastion.ini"
	./scripts/sh/run_ansible_against_jenkins_master.sh "qa" "initial" "ec2-bastion.ini"
	rm -rf ~/.ansible/tmp
	echo "Running Ansible against proxy instance for SSL configuration... (can be 10+ seconds before output)"
	EC2_INI_PATH="environments/qa/ec2-bastion.ini" \
		ansible-playbook -i "environments/qa" \
		--private-key="~/.ssh/ansible_qa" \
		--limit=haproxy \
		--vault-password-file=~/.ansible/vault-pass \
		-e "cloud_environment=qa" \
		-u ansible ansible/haproxy-ssl-config.yml
	python ./scripts/py/run_ansible_against_windows_slaves.py "qa" "ec2-bastion.ini"
	./scripts/sh/reboot_all_instances.sh "qa"

provision-jenkins-qa-aws-reprovision:
	./scripts/sh/install_external_java_role.sh
	./scripts/sh/update_machine.sh "jenkins_master" "qa"
	./scripts/sh/update_machine.sh "haproxy" "qa"
	./scripts/sh/run_ansible_against_haproxy.sh "qa" "reprovision" "ec2-bastion.ini"
	./scripts/sh/run_ansible_against_jenkins_master.sh "qa" "reprovision" "ec2-bastion.ini"
	rm -rf ~/.ansible/tmp
	echo "Running Ansible against proxy instance for SSL configuration... (can be 10+ seconds before output)"
	EC2_INI_PATH="environments/qa/ec2-bastion.ini" \
		ansible-playbook -i "environments/qa" \
		--private-key="~/.ssh/ansible_qa" \
		--limit=haproxy \
		--vault-password-file=~/.ansible/vault-pass \
		-e "cloud_environment=qa" \
		-u ansible ansible/haproxy-ssl-config.yml
	python ./scripts/py/run_ansible_against_windows_slaves.py "qa" "ec2-bastion.ini"

provision-jenkins-staging-aws-initial:
	./scripts/sh/install_external_java_role.sh
	./scripts/sh/update_machine.sh "jenkins_master" "staging"
	./scripts/sh/update_machine.sh "haproxy" "staging"
	./scripts/sh/run_ansible_against_haproxy.sh "staging" "initial" "ec2-bastion.ini"
	./scripts/sh/run_ansible_against_jenkins_master.sh "staging" "initial" "ec2-bastion.ini"
	rm -rf ~/.ansible/tmp
	echo "Running Ansible against proxy instance for SSL configuration... (can be 10+ seconds before output)"
	EC2_INI_PATH="environments/staging/ec2-bastion.ini" \
		ansible-playbook -i "environments/staging" \
		--private-key="~/.ssh/ansible_staging" \
		--limit=haproxy \
		--vault-password-file=~/.ansible/vault-pass \
		-e "cloud_environment=staging" \
		-u ansible ansible/haproxy-ssl-config.yml
	python ./scripts/py/run_ansible_against_windows_slaves.py "staging" "ec2-bastion.ini"
	./scripts/sh/reboot_all_instances.sh "staging"

provision-jenkins-staging-aws-reprovision:
	./scripts/sh/install_external_java_role.sh
	./scripts/sh/update_machine.sh "jenkins_master" "staging"
	./scripts/sh/update_machine.sh "haproxy" "staging"
	./scripts/sh/run_ansible_against_haproxy.sh "staging" "reprovision" "ec2-bastion.ini"
	./scripts/sh/run_ansible_against_jenkins_master.sh "staging" "reprovision" "ec2-bastion.ini"
	rm -rf ~/.ansible/tmp
	echo "Running Ansible against proxy instance for SSL configuration... (can be 10+ seconds before output)"
	EC2_INI_PATH="environments/staging/ec2-bastion.ini" \
		ansible-playbook -i "environments/staging" \
		--private-key="~/.ssh/ansible_staging" \
		--limit=haproxy \
		--vault-password-file=~/.ansible/vault-pass \
		-e "cloud_environment=staging" \
		-u ansible ansible/haproxy-ssl-config.yml
	python ./scripts/py/run_ansible_against_windows_slaves.py "staging" "ec2-bastion.ini"

provision-jenkins-prod-aws-initial:
	./scripts/sh/install_external_java_role.sh
	./scripts/sh/update_machine.sh "jenkins_master" "prod"
	./scripts/sh/update_machine.sh "haproxy" "prod"
	./scripts/sh/run_ansible_against_haproxy.sh "prod" "initial" "ec2-bastion.ini"
	./scripts/sh/run_ansible_against_jenkins_master.sh "prod" "initial" "ec2-bastion.ini"
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
	./scripts/sh/reboot_all_instances.sh "prod"

provision-jenkins-prod-aws-reprovision:
	./scripts/sh/install_external_java_role.sh
	./scripts/sh/update_machine.sh "jenkins_master" "prod"
	./scripts/sh/update_machine.sh "haproxy" "prod"
	./scripts/sh/run_ansible_against_haproxy.sh "prod" "reprovision" "ec2-bastion.ini"
	./scripts/sh/run_ansible_against_jenkins_master.sh "prod" "reprovision" "ec2-bastion.ini"
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

provision-rust_slave-macos-high_sierra-x86_64-vagrant-vbox:
	ANSIBLE_SSH_PIPELINING=true ansible-playbook -i environments/vagrant/hosts \
		--limit=macos_rust_slave \
		--vault-password-file=~/.ansible/vault-pass \
		--private-key=~/.ssh/id_rsa \
		-e "cloud_environment=none" \
		ansible/osx-rust-slave.yml

provision-rust_slave-macos-high_sierra-x86_64-qa-aws:
	./scripts/sh/run_ansible_against_mac_slave.sh "qa" "192.168.1.190"

provision-from_external-rust_slave-macos-high_sierra-x86_64-qa-aws:
ifndef MACOS_SLAVE_SSH_IP_ADDRESS
	@echo "The MACOS_SLAVE_SSH_IP_ADDRESS environment variable must be set."
	@exit 1
endif
ifndef MACOS_SLAVE_SSH_PORT
	@echo "The MACOS_SLAVE_SSH_PORT environment variable must be set."
	@exit 1
endif
	./scripts/sh/run_ansible_against_mac_slave.sh \
		"qa" "${MACOS_SLAVE_SSH_IP_ADDRESS}" "${MACOS_SLAVE_SSH_PORT}"

provision-rust_slave-macos-high_sierra-x86_64-staging-aws:
	./scripts/sh/run_ansible_against_mac_slave.sh "staging" "192.168.1.190"

provision-from_external-rust_slave-macos-high_sierra-x86_64-staging-aws:
ifndef MACOS_SLAVE_SSH_IP_ADDRESS
	@echo "The MACOS_SLAVE_SSH_IP_ADDRESS environment variable must be set."
	@exit 1
endif
ifndef MACOS_SLAVE_SSH_PORT
	@echo "The MACOS_SLAVE_SSH_PORT environment variable must be set."
	@exit 1
endif
	./scripts/sh/run_ansible_against_mac_slave.sh \
		"staging" "${MACOS_SLAVE_SSH_IP_ADDRESS}" "${MACOS_SLAVE_SSH_PORT}"

provision-rust_slave-macos-high_sierra-x86_64-prod-aws:
	./scripts/sh/run_ansible_against_mac_slave.sh "prod" "192.168.1.190"

provision-from_external-rust_slave-macos-high_sierra-x86_64-prod-aws:
ifndef MACOS_SLAVE_SSH_IP_ADDRESS
	@echo "The MACOS_SLAVE_SSH_IP_ADDRESS environment variable must be set."
	@exit 1
endif
ifndef MACOS_SLAVE_SSH_PORT
	@echo "The MACOS_SLAVE_SSH_PORT environment variable must be set."
	@exit 1
endif
	./scripts/sh/run_ansible_against_mac_slave.sh \
		"prod" "${MACOS_SLAVE_SSH_IP_ADDRESS}" "${MACOS_SLAVE_SSH_PORT}"

clean-rust_slave-macos-high_sierra-x86_64:
	ANSIBLE_PIPELINING=True ansible-playbook -i environments/vagrant/hosts ansible/osx-teardown.yml

clean-vbox:
	./scripts/sh/destroy_local_vms.sh

clean-jenkins-dev-aws:
	cd terraform/dev && terraform destroy

clean-jenkins-prod-aws:
	cd terraform/prod && terraform destroy

clean-jenkins-staging-aws:
	cd terraform/staging && terraform destroy

clean-jenkins-qa-aws:
	cd terraform/qa && terraform destroy

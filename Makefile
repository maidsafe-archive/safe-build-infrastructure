build-windows-slave:
	if [ ! -d "packer_output" ]; then mkdir packer_output; fi
	if [ -f "packer_output/windows2012r2min-virtualbox.box" ]; then rm packer_output/windows2012r2min-virtualbox.box; fi
	packer validate templates/vbox-win2012r2.json
	packer build templates/vbox-win2012r2.json

jenkins_master-centos-7.5-x86_64:
	vagrant up jenkins_master --provision

rust_slave-centos-7.5-x86_64:
	vagrant up rust_slave-centos-7.5-x86_64 --provision

rust_slave-ubuntu-trusty-x86_64:
	vagrant up rust_slave-ubuntu-trusty-x86_64 --provision

docker_slave-centos-7.5-x86_64:
	vagrant up docker_slave-centos-7.5-x86_64 --provision

jenkins-environment: docker_slave-centos-7.5-x86_64 jenkins_master-centos-7.5-x86_64

base-windows-2012_r2-x86_64:
	vagrant up base-windows-2012_r2-x86_64 --provision

rust_slave_git_bash-windows-2012_r2-x86_64:
	vagrant up rust_slave_git_bash-windows-2012_r2-x86_64 --provision

rust_slave_msys2-windows-2012_r2-x86_64:
	vagrant up rust_slave_msys2-windows-2012_r2-x86_64 --provision

clean:
	vagrant destroy -f

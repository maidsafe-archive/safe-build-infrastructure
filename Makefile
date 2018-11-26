build-windows-slave:
	if [ ! -d "packer_output" ]; then mkdir packer_output; fi
	if [ -f "packer_output/windows2012r2min-virtualbox.box" ]; then rm packer_output/windows2012r2min-virtualbox.box; fi
	packer validate templates/vbox-win2012r2.json
	packer build templates/vbox-win2012r2.json

jenkins_master-centos_7:
	vagrant up jenkins_master --provision

centos-7-rust_slave:
	vagrant up centos-7-rust_slave --provision

ubuntu-trusty-rust_slave:
	vagrant up ubuntu-trusty-rust_slave --provision

windows-2012_r2-base:
	vagrant up windows-2012_r2-base --provision

windows-2012_r2-git_bash-rust_slave:
	vagrant up windows-2012_r2-git_bash-rust_slave --provision

windows-2012_r2-msys2-rust_slave:
	vagrant up windows-2012_r2-msys2-rust_slave --provision

clean:
	vagrant destroy -f

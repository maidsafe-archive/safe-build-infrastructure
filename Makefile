build-windows-slave:
	if [ ! -d "packer_output" ]; then mkdir packer_output; fi
	if [ -f "packer_output/windows2012r2min-virtualbox.box" ]; then rm packer_output/windows2012r2min-virtualbox.box; fi
	packer validate templates/vbox-win2012r2.json
	packer build templates/vbox-win2012r2.json

centos-7-rust-slave:
	vagrant up centos-7-rust-slave --provision

ubuntu-trusty-rust-slave:
	vagrant up ubuntu-trusty-rust-slave --provision

windows-2012_r2-base:
	vagrant up windows2012_r2-base --provision

windows-2012_r2-rust-slave:
	vagrant up windows2012_r2-rust-slave --provision

clean:
	vagrant destroy -f

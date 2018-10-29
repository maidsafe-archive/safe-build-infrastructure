centos-7-rust-slave:
	vagrant up centos-7-rust-slave --provision

ubuntu-trusty-rust-slave:
	vagrant up ubuntu-trusty-rust-slave --provision

clean:
	vagrant destroy -f

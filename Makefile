centos-7-rust-slave:
	vagrant up centos-7-rust-slave

ubuntu-trusty-rust-slave:
	vagrant up ubuntu-trusty-rust-slave

clean:
	vagrant destroy -f

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vbguest.auto_update = false

  config.vm.define "rust-slave" do |rust_slave|
    rust_slave.vm.box = "centos/7"
    rust_slave.vm.network :private_network, :ip => '192.168.100.100'
    rust_slave.vm.provision "shell", path: "scripts/setup_ansible.sh"
    rust_slave.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "rust-slave.yml"
      ansible.raw_arguments = "--vault-pass ~/.ansible/vault-pass"
    end
    rust_slave.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
    end
  end

  config.vm.provision :hosts do |hosts|
    hosts.add_host '192.168.100.100', ['rust-slave.vagrantup.internal']
  end
end

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vbguest.auto_update = false

  config.vm.define "centos-7-rust-slave" do |centos_7_rust_slave|
    centos_7_rust_slave.vm.box = "centos/7"
    centos_7_rust_slave.vm.provision "file", source: "~/.ansible/vault-pass", destination: "/home/vagrant/.ansible/vault-pass"
    centos_7_rust_slave.vm.provision "shell", path: "scripts/setup_ansible.sh"
    centos_7_rust_slave.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/rust-slave.yml"
      ansible.raw_arguments = "--vault-pass /home/vagrant/.ansible/vault-pass"
    end
    centos_7_rust_slave.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
    end
  end

  config.vm.define "ubuntu-trusty-rust-slave" do |ubuntu_trusty_rust_slave|
    ubuntu_trusty_rust_slave.vm.box = "ubuntu/trusty64"
    ubuntu_trusty_rust_slave.vm.provision "file", source: "~/.ansible/vault-pass", destination: "/home/vagrant/.ansible/vault-pass"
    ubuntu_trusty_rust_slave.vm.provision "shell", path: "scripts/setup_ansible.sh"
    ubuntu_trusty_rust_slave.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/rust-slave.yml"
      ansible.raw_arguments = "--vault-pass /home/vagrant/.ansible/vault-pass"
    end
    ubuntu_trusty_rust_slave.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
    end
  end

  config.vm.define "windows2012_r2-rust-slave" do |windows_slave|
    windows_slave.vm.box = "windows2012_r2"
    windows_slave.vm.box_url = "https://s3.amazonaws.com/safe-vagrant-boxes/windows2012r2-virtualbox.box"
    windows_slave.vm.guest = :windows
    windows_slave.vm.communicator = "winrm"
    windows_slave.winrm.username = "vagrant"
    windows_slave.winrm.password = "vagrant"
    windows_slave.vm.provision "shell", path: "scripts/bat/setup_mingw.bat"
    windows_slave.vm.provision "shell", path: "scripts/ps/install_rustup.ps1"
    windows_slave.vm.provision "shell", path: "scripts/bat/tools.bat"
    windows_slave.vm.provider "virtualbox" do |vb|
      vb.memory = 4096
      vb.gui = true
    end
  end
end

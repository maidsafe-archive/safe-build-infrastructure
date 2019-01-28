# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vbguest.auto_update = false

  config.vm.define "jenkins_master-centos-7.5-x86_64" do |jenkins_master|
    jenkins_master.vm.box = "centos/7"
    jenkins_master.vm.network :private_network, :ip => "#{ENV['JENKINS_MASTER_IP_ADDRESS']}"
    jenkins_master.vm.provision "file", source: "~/.ansible/vault-pass", destination: "/home/vagrant/.ansible/vault-pass"
    jenkins_master.vm.provision "shell", path: "scripts/setup_ansible.sh"
    jenkins_master.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/jenkins-master.yml"
      ansible.inventory_path = "environments/vagrant/hosts"
      ansible.raw_arguments = "--vault-pass /home/vagrant/.ansible/vault-pass"
    end
    jenkins_master.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.customize ["modifyvm", :id, "--audio", "none"]
    end
  end

  config.vm.define "rust_slave-centos-7.5-x86_64" do |rust_slave_centos|
    rust_slave_centos.vm.box = "centos/7"
    rust_slave_centos.vm.provision "file", source: "~/.ansible/vault-pass", destination: "/home/vagrant/.ansible/vault-pass"
    rust_slave_centos.vm.provision "shell", path: "scripts/setup_ansible.sh"
    rust_slave_centos.vm.provision "shell", path: "scripts/install_external_java_role.sh", privileged: false
    rust_slave_centos.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/rust-slave.yml"
      ansible.raw_arguments = "--vault-pass /home/vagrant/.ansible/vault-pass"
    end
    rust_slave_centos.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.customize ["modifyvm", :id, "--audio", "none"]
    end
  end

  config.vm.define "docker_slave-centos-7.5-x86_64" do |docker_slave_centos|
    docker_slave_centos.vm.box = "centos/7"
    docker_slave_centos.vm.network :private_network, :ip => "#{ENV['DOCKER_SLAVE_IP_ADDRESS']}"
    docker_slave_centos.vm.provision "file", source: "~/.ansible/vault-pass", destination: "/home/vagrant/.ansible/vault-pass"
    docker_slave_centos.vm.provision "shell", path: "scripts/setup_ansible.sh"
    docker_slave_centos.vm.provision "shell", path: "scripts/install_external_java_role.sh", privileged: false
    docker_slave_centos.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/docker-slave.yml"
      ansible.inventory_path = "environments/vagrant/hosts"
      ansible.raw_arguments = "--vault-pass /home/vagrant/.ansible/vault-pass"
    end
    docker_slave_centos.vm.provider "virtualbox" do |vb|
      vb.cpus = 2
      vb.memory = 2048
      vb.customize ["modifyvm", :id, "--audio", "none"]
    end
  end

  config.vm.define "rust_slave-ubuntu-trusty-x86_64" do |rust_slave_ubuntu|
    rust_slave_ubuntu.vm.box = "ubuntu/trusty64"
    rust_slave_ubuntu.vm.provision "file", source: "~/.ansible/vault-pass", destination: "/home/vagrant/.ansible/vault-pass"
    rust_slave_ubuntu.vm.provision "shell", path: "scripts/setup_ansible.sh"
    rust_slave_ubuntu.vm.provision "shell", path: "scripts/install_external_java_role.sh", privileged: false
    rust_slave_ubuntu.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/rust-slave.yml"
      ansible.raw_arguments = "--vault-pass /home/vagrant/.ansible/vault-pass"
    end
    rust_slave_ubuntu.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
    end
  end

  config.vm.define "base-windows-2012_r2-x86_64" do |windows_slave|
    windows_slave.vm.box = "windows2012_r2"
    windows_slave.vm.box_url = "https://s3.amazonaws.com/safe-vagrant-boxes/windows2012r2-virtualbox.box"
    windows_slave.vm.guest = :windows
    windows_slave.vm.communicator = "winrm"
    windows_slave.winrm.username = "vagrant"
    windows_slave.winrm.password = "vagrant"
    windows_slave.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.gui = true
      vb.customize ["modifyvm", :id, "--audio", "none"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    end
  end

  config.vm.define "base-windows-2016-x86_64" do |windows_slave|
    windows_slave.vm.box = "windows2016"
    windows_slave.vm.box_url = "https://s3.amazonaws.com/safe-vagrant-boxes/windows2016-virtualbox.box"
    windows_slave.vm.guest = :windows
    windows_slave.vm.communicator = "winrm"
    windows_slave.winrm.username = "vagrant"
    windows_slave.winrm.password = "vagrant"
    windows_slave.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.gui = true
      vb.customize ["modifyvm", :id, "--audio", "none"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    end
  end

  config.vm.define "rust_slave_git_bash-windows-2012_r2-x86_64" do |windows_slave|
    windows_slave.vm.box = "windows2012_r2"
    windows_slave.vm.box_url = "https://s3.amazonaws.com/safe-vagrant-boxes/windows2012r2-virtualbox.box"
    windows_slave.vm.guest = :windows
    windows_slave.vm.communicator = "winrm"
    windows_slave.winrm.username = "vagrant"
    windows_slave.winrm.password = "vagrant"
    windows_slave.vm.provision "shell", inline: "choco install -y git"
    windows_slave.vm.provision "shell", path: "scripts/ps/install_rustup.ps1"
    windows_slave.vm.provision "shell", path: "scripts/bat/tools.bat"
    windows_slave.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.gui = true
      vb.customize ["modifyvm", :id, "--audio", "none"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    end
  end

  config.vm.define "travis_rust_slave-windows-2016-x86_64" do |windows_slave|
    windows_slave.vm.box = "maidsafe/windows-2016-travis_slave"
    windows_slave.vm.box_url = "https://s3.amazonaws.com/safe-vagrant-boxes/travis_slave-windows-2016-virtualbox-x86_64.box"
    windows_slave.vm.guest = :windows
    windows_slave.vm.communicator = "winrm"
    windows_slave.winrm.username = "vagrant"
    windows_slave.winrm.password = "vagrant"
    windows_slave.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/jenkins-slave-windows.yml"
      ansible.inventory_path = "environments/vagrant/hosts"
      ansible.vault_password_file = "~/.ansible/vault-pass"
      ansible.extra_vars = {
        jenkins_master_url: "#{ENV['JENKINS_MASTER_IP_ADDRESS']}"
      }
    end
    windows_slave.vm.provision "shell", path: "scripts/ps/install_rustup.ps1"
    windows_slave.vm.provision "shell", path: "scripts/bat/tools.bat"
    windows_slave.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.gui = true
      vb.customize ["modifyvm", :id, "--audio", "none"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    end
  end

  config.vm.define "rust_slave_msys2-windows-2012_r2-x86_64" do |windows_slave|
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
      vb.memory = 2048
      vb.gui = true
      vb.customize ["modifyvm", :id, "--audio", "none"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    end
  end

  config.vm.provision :hosts do |hosts_config|
    hosts_config.add_host "#{ENV['JENKINS_MASTER_IP_ADDRESS']}", ["#{ENV['JENKINS_MASTER_URL']}"]
    hosts_config.add_host "#{ENV['DOCKER_SLAVE_IP_ADDRESS']}", ["#{ENV['DOCKER_SLAVE_URL']}"]
  end
end

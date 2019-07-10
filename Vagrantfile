# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vbguest.auto_update = false

  config.vm.define "jenkins_master-centos-7.6-x86_64" do |jenkins_master|
    jenkins_master.vm.box = "centos/7"
    jenkins_master.vm.network :private_network, :ip => "#{ENV['JENKINS_MASTER_IP_ADDRESS']}"
    jenkins_master.vm.provision "file", source: "~/.ansible/vault-pass", destination: "/home/vagrant/.ansible/vault-pass"
    jenkins_master.vm.provision "shell", path: "scripts/sh/setup_ansible.sh"
    jenkins_master.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/jenkins-master.yml"
      ansible.inventory_path = "environments/vagrant/hosts"
      ansible.raw_arguments = "--vault-pass /home/vagrant/.ansible/vault-pass"
      ansible.extra_vars = {
        cloud_environment: "none",
        jenkins_master_url: "http://#{ENV['JENKINS_MASTER_IP_ADDRESS']}/"
      }
    end
    jenkins_master.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.customize ["modifyvm", :id, "--audio", "none"]
    end
  end

  config.vm.define "rust_slave-centos-7.6-x86_64" do |rust_slave_centos|
    rust_slave_centos.vm.box = "centos/7"
    rust_slave_centos.vm.provision "file", source: "~/.ansible/vault-pass", destination: "/home/vagrant/.ansible/vault-pass"
    rust_slave_centos.vm.provision "shell", path: "scripts/sh/setup_ansible.sh"
    rust_slave_centos.vm.provision "shell", path: "scripts/sh/install_external_java_role.sh", privileged: false
    rust_slave_centos.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/rust-slave.yml"
      ansible.raw_arguments = "--vault-pass /home/vagrant/.ansible/vault-pass"
    end
    rust_slave_centos.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.customize ["modifyvm", :id, "--audio", "none"]
    end
  end

  config.vm.define "docker_slave_quick-centos-7.6-x86_64" do |docker_slave_quick|
    docker_slave_quick.vm.box = "maidsafe/docker_slave-centos-7.6-x86_64"
    docker_slave_quick.vm.network :private_network, :ip => "#{ENV['DOCKER_SLAVE_IP_ADDRESS']}"
    docker_slave_quick.vm.provider "virtualbox" do |vb|
      vb.cpus = 2
      vb.memory = 2048
      vb.customize ["modifyvm", :id, "--audio", "none"]
    end
  end

  config.vm.define "docker_slave-centos-7.6-x86_64" do |docker_slave_centos|
    docker_slave_centos.vm.box = "centos/7"
    docker_slave_centos.vm.network :private_network, :ip => "#{ENV['DOCKER_SLAVE_IP_ADDRESS']}"
    docker_slave_centos.vm.provision "file", source: "~/.ansible/vault-pass", destination: "/home/vagrant/.ansible/vault-pass"
    docker_slave_centos.vm.provision "shell", path: "scripts/sh/setup_ansible.sh"
    docker_slave_centos.vm.provision "shell", path: "scripts/sh/install_external_java_role.sh", privileged: false
    docker_slave_centos.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/docker-slave.yml"
      ansible.inventory_path = "environments/vagrant/hosts"
      ansible.raw_arguments = "--vault-pass /home/vagrant/.ansible/vault-pass"
      ansible.extra_vars = { cloud_environment: "none" }
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
    rust_slave_ubuntu.vm.provision "shell", path: "scripts/sh/setup_ansible.sh"
    rust_slave_ubuntu.vm.provision "shell", path: "scripts/sh/install_external_java_role.sh", privileged: false
    rust_slave_ubuntu.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/rust-slave.yml"
      ansible.raw_arguments = "--vault-pass /home/vagrant/.ansible/vault-pass"
    end
    rust_slave_ubuntu.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
    end
  end

  config.vm.define "base-windows-2012_r2-x86_64" do |windows_slave|
    windows_slave.vm.synced_folder '.', '/vagrant', disabled: true
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
    windows_slave.vm.synced_folder '.', '/vagrant', disabled: true
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
    windows_slave.vm.synced_folder '.', '/vagrant', disabled: true
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

  config.vm.define "jenkins_rust_slave-windows-2016-x86_64" do |windows_slave|
    windows_slave.vm.synced_folder '.', '/vagrant', disabled: true
    windows_slave.vm.box = "maidsafe/windows-2016-travis_slave"
    windows_slave.vm.box_url = "https://s3.amazonaws.com/safe-vagrant-boxes/travis_slave-windows-2016-virtualbox-x86_64.box"
    windows_slave.vm.guest = :windows
    windows_slave.vm.communicator = "winrm"
    windows_slave.winrm.username = "vagrant"
    windows_slave.winrm.password = "vagrant"
    windows_slave.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/win-jenkins-slave.yml"
      ansible.inventory_path = "environments/vagrant/hosts"
      ansible.vault_password_file = "~/.ansible/vault-pass"
      ansible.extra_vars = {
        jenkins_master_dns: "#{ENV['JENKINS_MASTER_IP_ADDRESS']}"
      }
    end
    windows_slave.vm.provision "shell", path: "scripts/bat/tools.bat"
    windows_slave.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.gui = true
      vb.customize ["modifyvm", :id, "--audio", "none"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    end
  end

  config.vm.define "travis_rust_slave-windows-2016-x86_64" do |windows_slave|
    windows_slave.vm.synced_folder '.', '/vagrant', disabled: true
    windows_slave.vm.box = "maidsafe/windows-2016-travis_slave"
    windows_slave.vm.box_url = "https://s3.amazonaws.com/safe-vagrant-boxes/travis_slave-windows-2016-virtualbox-x86_64.box"
    windows_slave.vm.guest = :windows
    windows_slave.vm.communicator = "winrm"
    windows_slave.winrm.username = "vagrant"
    windows_slave.winrm.password = "vagrant"
    windows_slave.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/win-travis-slave.yml"
      ansible.limit = "travis_rust_slave-windows-2016-x86_64"
      ansible.inventory_path = "environments/vagrant/hosts"
      ansible.vault_password_file = "~/.ansible/vault-pass"
      ansible.extra_vars = {
        jenkins_service_account_user: "" # This is necessary to instruct the role *not* to use the service account.
      }
    end
    windows_slave.vm.provision "shell", path: "scripts/bat/tools.bat"
    windows_slave.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.gui = true
      vb.customize ["modifyvm", :id, "--audio", "none"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    end
  end

  config.vm.define "rust_slave_msys2-windows-2012_r2-x86_64" do |windows_slave|
    windows_slave.vm.synced_folder '.', '/vagrant', disabled: true
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

  config.vm.define "docker_slave-centos-7.6-x86_64-aws" do |docker_slave_aws|
    docker_slave_aws.vm.box = "dummy"
    docker_slave_aws.vm.provider :aws do |aws, override|
      aws.access_key_id = "#{ENV['AWS_ACCESS_KEY_ID']}"
      aws.secret_access_key = "#{ENV['AWS_SECRET_ACCESS_KEY']}"
      aws.region = "eu-west-2"
      aws.ami = "ami-0eab3a90fc693af19"
      aws.instance_type = "t2.micro"
      aws.security_groups = ["vagrant"]
      aws.keypair_name = "vagrant"
      aws.block_device_mapping = [
        {
          'DeviceName' => '/dev/sdb',
          'Ebs.VolumeSize' => 50,
          'Ebs.DeleteOnTermination' => true,
          'Ebs.VolumeType' => 'gp2'
        },
        {
          'DeviceName' => '/dev/sdc',
          'Ebs.VolumeSize' => 50,
          'Ebs.DeleteOnTermination' => true,
          'Ebs.VolumeType' => 'gp2'
        }
      ]
      aws.tags = {
        'Name' => 'docker_slave_001',
        'full_name' => 'docker_slave-centos-7.6-x86_64',
        'group' => 'slaves',
        'environment' => 'dev'
      }
      override.ssh.username = "centos"
      override.ssh.private_key_path = "~/.ssh/vagrant"
    end
  end

  config.vm.define "util_slave-ubuntu-bionic-x86_64-aws" do |docker_slave_aws|
    docker_slave_aws.vm.box = "dummy"
    docker_slave_aws.vm.synced_folder ".", "/vagrant", disabled: true
    docker_slave_aws.vm.provider :aws do |aws, override|
      aws.access_key_id = "#{ENV['AWS_ACCESS_KEY_ID']}"
      aws.secret_access_key = "#{ENV['AWS_SECRET_ACCESS_KEY']}"
      aws.region = "eu-west-2"
      aws.ami = "ami-0883141bc92a74917"
      aws.instance_type = "t2.micro"
      aws.security_groups = ["vagrant"]
      aws.keypair_name = "vagrant"
      aws.block_device_mapping = [
        {
          'DeviceName' => '/dev/sdb',
          'Ebs.VolumeSize' => 50,
          'Ebs.DeleteOnTermination' => true,
          'Ebs.VolumeType' => 'gp2'
        },
        {
          'DeviceName' => '/dev/sdc',
          'Ebs.VolumeSize' => 50,
          'Ebs.DeleteOnTermination' => true,
          'Ebs.VolumeType' => 'gp2'
        }
      ]
      aws.tags = {
        'Name' => 'util_slave',
        'full_name' => 'util_slave-ubuntu-bionic-x86_64',
        'group' => 'util_slaves',
        'environment' => 'dev'
      }
      override.ssh.username = "ubuntu"
      override.ssh.private_key_path = "~/.ssh/vagrant"
    end
  end

  config.vm.provision :hosts do |hosts_config|
    hosts_config.add_host "#{ENV['JENKINS_MASTER_IP_ADDRESS']}", ["#{ENV['JENKINS_MASTER_URL']}"]
    hosts_config.add_host "#{ENV['DOCKER_SLAVE_IP_ADDRESS']}", ["#{ENV['DOCKER_SLAVE_URL']}"]
  end

  config.vm.define "kali_linux-v2019.2.0-x86_64" do |kali_linux|
    kali_linux.vm.box = "offensive-security/kali-linux"
    kali_linux.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.customize ["modifyvm", :id, "--vram", "128"]
    end
  end

  config.vm.define "pen_test_desktop-lubuntu-18.04.04-x86_64" do |lubuntu_desktop|
    lubuntu_desktop.vm.box = "chenhan/lubuntu-desktop-18.04"
    lubuntu_desktop.vm.box_version = "20180704.0.0"
    lubuntu_desktop.vm.provision "shell", path: "scripts/sh/loicsetup.sh"
    lubuntu_desktop.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.customize ["modifyvm", :id, "--vram", "128"]
    end
  end

end

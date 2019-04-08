# Build Infrastructure

This repository houses automated build infrastructure for various Maidsafe projects. The purpose is to provide reproducible build environments for a Jenkins-based system or for developers who need a known configuration for debugging build problems; doing our builds from known configurations reduces the 'it works on my machine' effect.

Right now there are only some VMs available, but hopefully shortly we can provide some Docker containers for running builds in.

## Setup

To get the VMs up and running, you need some things installed on your development host:

* [Vagrant](https://www.vagrantup.com/). Generally just get the latest version for your distro. You can run it on a Linux, Windows or macOS host. Please note, there are Windows boxes in this repo and those require WinRM for communication. We seen some problems with this when installing Vagrant from a package manager, so download the latest package from the [Vagrant downloads](https://www.vagrantup.com/downloads.html) section.
* After installing Vagrant, install a couple of plugins for it:
  - [vagrant-hosts](https://github.com/oscar-stack/vagrant-hosts): `vagrant plugin install vagrant-hosts`.
  - [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest): `vagrant plugin install vagrant-vbguest`.
* [Virtualbox](https://www.virtualbox.org/wiki/Downloads). The list of versions supported by Vagrant is [here](https://www.vagrantup.com/docs/virtualbox/). Sometimes the latest versions aren't supported yet, but generally it's OK to just grab the latest version.
* [Ansible](https://docs.ansible.com/). Ansible is needed on the host to bring the Windows machines online. The easiest way to install Ansible is via pip. At the moment we actually need the latest development version of Ansible. This is because there is a fix related to the Chocolately package manager for Windows that isn't in released versions yet. You can install the development version of Ansible with `pip install git+https://github.com/ansible/ansible.git@devel`. Consider installing into a [virtualenv](https://virtualenv.pypa.io/en/latest/) so that you can vary the version used quite easily.
* [Python Powershell Remoting Protocol Client](https://github.com/jborean93/pypsrp). Needed for bringing up the Windows Jenkins slaves if you're on a Linux or macOS host. Even though an SSH server is available for Windows, Ansible doesn't support it, so the communication has to be done via WinRM. This library enables communication from Linux/macOS -> Windows via WinRM. The easiest way to install it is via pip: `pip install pypsrp`. If you don't have it, there are [lots of ways to install pip](https://pip.pypa.io/en/stable/installing/). You can install pip packages system with `sudo`, or if you don't want to do that, you can run it with the `--user` switch. As per Ansible, you can also consider installing this into a virtualenv. If you install Ansible into a virtualenv, you also need to install this library into it.
* The easiest way to get machines running are via the convenience targets in the Makefile. Most Linux distros will probably have `make` installed via other packages like `build-essentials`. Google for how to install it on your distro. On Windows you can get access to `make` by installing [MSYS2](http://www.msys2.org/) then running `pacman -S make`; after this add `c:\msys64\usr\bin` to your `PATH` variable to have `make` accessible via `cmd.exe`. On macOS you can install via the [Apple Developer Tools](http://developer.apple.com/) and there's also a package available for [Homebrew](https://formulae.brew.sh/formula/make).
* Get a copy of the Ansible vault password from someone in QA, then put that in `~/.ansible/vault-pass` on the host.

Of course, for everything here that's installed via pip, you can considering using a [virtualenv](https://virtualenv.pypa.io/en/latest/) (and [virtualenvwrapper](https://virtualenvwrapper.readthedocs.io/en/latest/) is even better). This is a good solution for running experimental versions of Ansible. You can have a different virtualenv for each installation.

**Important note**: if you're running macOS, there's an [issue](https://github.com/ansible/ansible/issues/32499) with using Ansible to provision Windows hosts. You can work around this issue by setting an environment variable: `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES`. Add this to your `~/.bashrc` to prevent having to set it all the time.

If you want to build the Windows boxes you will need a [Packer](https://packer.io/) installation; however this isn't necessary for running the Vagrant boxes, as the boxes will be hosted on S3.

## VMs

What follows is a list of some of the VMs available in this repository. The names here correspond to the targets in the Makefile, so you can run `make <name>` to produce any of these machines:

| Name                                               | OS              | Description                                                                                                                                                                                          | Installed Contents                                                                                                                                                                              |
| ----                                               | --              | -----------                                                                                                                                                                                          | --------                                                                                                                                                                                        |
| vm-jenkins_master-centos-7.6-x86_64-vbox           | CentOS 7.6      | Use as a Jenkins host. Jenkins is hosted in a Docker container. At the moment this will come up with a minimal setup.                                                                                | Docker, docker-compose                                                                                                                                                                          |
| vm-docker_slave-centos-7.6-x86_64-vbox             | CentOS 7.6      | Use as a build slave for Jenkins. This only has Docker installed on it and a jenkins user that allows Jenkins to connect to the slave.                                                               | Java, Docker, docker-compose                                                                                                                                                                    |
| vm-rust_slave-ubuntu-trusty-x86_64-vbox            | Ubuntu 14.04    | Use for building Rust applications on Ubuntu. This version of Ubuntu matches the version in use on Travis, so it should be very similar to their environment.                                        | gcc, libssl-dev, pkg-config, musl-dev, musl-tools, rust 1.32.0, x86_64-unknown-linux-musl target, cargo-script                                                                                  |
| vm-rust_slave-centos-7.6-x86_64-vbox               | CentOS 7.6      | Use for building Rust applications on CentOS. Currently it won't build due to a weird issue with openssl.                                                                                            | gcc, openssl-devel, musl compiled from source (no packages on available on CentOS), rust 1.32.0, x86_64-unknown-linux-musl target, cargo-script                                                 |
| vm-base-windows-2012_r2-x86_64-vbox                | Windows 2012 R2 | Use as a base box when you need a completely clean machine.                                                                                                                                          | Only the base operating system.                                                                                                                                                                 |
| vm-rust_slave_git_bash-windows-2012_r2-x86_64-vbox | Windows 2012 R2 | Use for building Crust on Windows. This is setup to use MinGW rather than MSVC.                                                                                                                      | MSYS2, mingw-w64-x86_64-gcc, rust 1.32.0, ConEmu, Chrome (the last 2 are just for alternatives to the unfortunately poor default tools on Windows).                                             |
| vm-rust_slave_msys2-windows-2012_r2-x86_64-vbox    | Windows 2012 R2 | Use for debugging issues running Windows builds on Travis, which uses Git Bash as a shell. The reason why it's a separate box is because sometimes Git Bash and MSYS2 can interfere with each other. | Git Bash, rust 1.32.0, ConEmu, Chrome (the last 2 are just for alternatives to the unfortunately poor default tools on Windows).                                                                |
| vm-jenkins_rust_slave-windows-2016-x86_64-vbox     | Windows 2016    | Use for building Rust applications on Windows with an environment closely matching Travis. Also functions as a Jenkins slave, so this needs to be used in combination with a Jenkins master.         | All the packages in the Travis Windows environment, rust 1.32.0, ConEmu, Chrome (the last 2 are just for alternatives to the unfortunately poor default tools on Windows), Jenkins slave agent. |
| vm-travis_rust_slave-windows-2016-x86_64-vbox      | Windows 2016    | Use for building Rust applications on Windows with an environment closely matching Travis.                                                                                                           | All the packages in the Travis Windows environment, rust 1.32.0, ConEmu, Chrome (the last 2 are just for alternatives to the unfortunately poor default tools on Windows).                      |

The Linux boxes here use the official, publicly available Vagrant base boxes. There aren't really any reliable base boxes available for Windows, so this repo contains a [Packer](https://www.packer.io/intro/) template for building the Windows box.

## Jenkins

A Jenkins environment is declared in this repository. It runs in a Docker container. The container is slightly customised to provide a list of plugins to install, but that custom definition bases from the [official container image](https://hub.docker.com/r/jenkins/jenkins/). There's also a [postfix container](https://hub.docker.com/r/tozd/postfix/) in the setup to use as an SMTP server. To make the link between these containers easier to manage, we are making use of [Docker Compose](https://docs.docker.com/compose/). Finally, the Compose definition is managed as a systemd service, allowing simple management of the containers. For example, to restart Jenkins, you can simply run `systemctl restart jenkins`.

### Local Provision

To get a local Jenkins environment, simply run `make env-jenkins-dev-vbox`. This will bring up the Jenkins master, along with a Linux and a Windows slave. Note that at the end of this process, the Windows machine will be rebooted to allow PATH related changes to take effect. The Linux slave only really has Docker on it, but the Windows machine replicates the [Travis Windows environment](https://docs.travis-ci.com/user/reference/windows/). The Windows machine comes up after the Jenkins master, since the master needs to be available for the Jenkins slave service to start successfully. After the provisioning process is complete, Jenkins should be accessible in your browser at `192.168.10.100:8080`. You can login with the user `chriso` - speak to someone in QA to get the password.

### AWS Development Provision

It's possible to get an environment on AWS, but there is some setup required.

**Important note:** at the moment this provision will only run from a Linux host. There is an [issue](https://github.com/ansible/ansible/issues/32499) with Python on macOS that prevents Ansible provisioning the Windows host. Unfortunately, the suggested workaround doesn't seem to work for this particular case (though we did see it working for other cases).

First, do the following:

* Install [jq](https://stedolan.github.io/jq/) on your platform.
* Install the AWSCLI on your platform. It's very easy to install with pip: `sudo pip install awscli`.
* The [ec2.py](https://github.com/ansible/ansible/blob/devel/contrib/inventory/ec2.py) requires a boto installation: `sudo pip install boto`.
* Save [ec2.ini](https://github.com/ansible/ansible/blob/devel/contrib/inventory/ec2.ini) at `/etc/ansible/ec2.ini`.
* Edit `/etc/ansible/ec2.ini` an uncomment the `#hostname_variable = tag_Name` by removing the hash at the start.
* Set `export AWS_ACCESS_KEY_ID=<your key ID>` to the access key ID for your account.
* Set `export AWS_SECRET_ACCESS_KEY=<your secret access key>` to the secret access key for your account.
* Set `export AWS_KEYPAIR_NAME=jenkins_env`.
* Set `export AWS_PRIVATE_KEY_PATH=~/.ssh/jenkins_env_key` (get a copy of the key from someone in QA).

For the environment variables, it's probably better to put them in some kind of file and source that as part of your `~/.bashrc`.

After that you can run `make env-jenkins-dev-aws`. This creates:

* A security group with the necessary ports opened
* 2 CentOS Linux machines to be used as Docker slaves
* 1 Windows machine to be used as a slave
* 1 CentOS Linux machine to be used as the Jenkins master
* Provisions all the machines using Ansible

Unfortunately, using the [Chocolatey](https://chocolatey.org/) package manager for the Windows machine sometimes results in itermittent failures when trying to pull the packages. If this happens, start the process again by running `make env-jenkins-dev-aws`.

This setup is intended *only* for development. The machines are all running on the default VPC and Jenkins doesn't have HTTPS enabled.

At the end the Jenkins URL will be printed to the console. As with the local environment, see someone in QA to get the admin password for Jenkins.

When you're finished, you can tear the environment down by running `make clean-jenkins-dev-aws`.

### AWS Production Provision

Our production infrastructure for Jenkins runs in its own VPC, with a public subnet containing the Jenkins master and a Bastion host, and a private subnet containing the slaves. Producing this environment is a semi-automated process with 2 parts: the infrastructure is created, then we SSH to the Bastion host to provision the machines.

#### Setup Prerequisites

On your development host:

* Install [Terraform](https://www.terraform.io/) on your distribution. Terraform is distributed as a single binary file, so you can either just extract it to somewhere on PATH, or put it somewhere and then symlink it to a location on PATH.
* Terraform needs to connect to AWS, so you need to supply your keys:
  - `export AWS_ACCESS_KEY_ID=<your access key id>`
  - `export AWS_SECRET_ACCESS_KEY=<your secret access key>`
* Save [ec2.ini](https://github.com/ansible/ansible/blob/devel/contrib/inventory/ec2.ini) at `/etc/ansible/ec2.ini`.
* Get a copy of the Ansible SSH key from someone in QA and save this somewhere like `~/.ssh/ansible`, then run `chmod 0400 ~/.ssh/ansible`.
  
#### Creating the Infrastructure

After setting up Terraform and providing the AWS details, we can bring up the infrastructure by running `make env-jenkins-prod-aws`.

After the infrastructure is created with Terraform, the Bastion host will be provisioned with Ansible. Before that 2nd step occurs, there's a sleep for 2 minutes to allow a yum update to complete (this is initiated with a user data script when the instance launches). When this target finishes we then need to SSH into the Bastion host and provision the created infrastructure.

#### Provisioning the Infrastructure

Log into the AWS GUI or use the CLI to retrieve the public hostname of the Bastion. The machine is tagged with `Name=ansible_bastion`, which you can see in the GUI. SSH to this machine using the Ansible key referred to earlier: `ssh -i ~/.ssh/ansible ansible@<public hostname>`.

The provisioning for this machine cloned this repository and changed the branch for convenience. It also created a virtualenv with Ansible and other Python libraries that are necessary for provisioning our machines.

Now perform the following steps (all of these have to be applied to the Bastion host):

* Set your AWS access key ID: `export AWS_ACCESS_KEY_ID=<access key id>`
* Set your AWS secret key: `export AWS_SECRET_ACCESS_KEY=<secret access key>`
* Get the ID of the private subnet for the slaves and set that:
    - In the AWS GUI go to Services -> VPC -> Subnets -> jenkins_environment-private-eu-west-2 and copy the ID of the subnet
    - `export SLAVE_SUBNET_ID=<private subnet ID>`
* Get a copy of the Ansible vault password from someone in QA and save it to `~/.ansible/vault-pass`
* Activate the virtualenv for necessary Python apps/libs: `cd ~/safe-build-infrastructure && source venv/bin/activate`
* Run the provisioning: `make provision-jenkins-prod-aws`
* Finally, after the provisioning has completed, go into the AWS GUI and issue a restart for the Windows slave.

After the provisioning is complete, go to the AWS GUI and get the address of the Jenkins master, then open `http://<jenkins master hostname>:8080/` in your browser. Log in using the same details as usual.

### Configure Jenkins

After you've provisioned the environment either locally or on AWS, it needs a little bit of manual configuration to get things running.

If you're running on AWS with the EC2 plugin, this requires one manual step to get working. Go to Manage Jenkins -> Configure System -> Cloud Section -> EC2 Key Pair's Private Key then paste in the `jenkins_env` private key and click on 'Save'.

The instance is using the [Job DSL plugin](https://github.com/jenkinsci/job-dsl-plugin) to define all the jobs in code. This requires a 'seed' job to be created manually. After that's created, all the other job definitions will be created from the seed. When Jenkins is up and running you need to create this seed job. After logging in, perform the following steps:

* Create a new 'freestyle' job to function as the seed (I usually call it 'freestyle-job_seed')
* Add a build step by selecting 'Process Job DSL' from the drop down
* Select 'Use the provided DSL script'
* Paste the contents of the 'ansible/roles/jenkins-master/files/job_dsl_seed.groovy' file in this repository into the textbox
* Save the job then run it

After running the seed job, this will generate all the other jobs. At the time of writing there is only a pipeline for [Safe Client Libs](https://github.com/maidsafe/safe_client_libs). I would recommend switching to the [Blue Ocean](https://jenkins.io/projects/blueocean/) view.

### macOS Slaves

Our environment contains some macOS slaves that we're running on physical hardware. These need to be manually configured to allow remote login, and to install XCode Developer Tools and Homebrew. Everything else can be done with Ansible. Follow these steps to setup - note that these instruction were written for macOS 10.14.3, other versions may vary:

* Enable 'Remote Login': System Preferences -> Sharing -> Tick Remote Login Checkbox
* `xcode-select --install` to install the XCode Developer Tools
* `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"` to install Homebrew
* `brew tap homebrew/homebrew-core`
* Disable PAM authentication by editing `/etc/ssh/sshd_config` and changing `UsePAM yes` to `UsePAM no` (jenkins user can't SSH in without this)
* Give the `qamaidsafe` user passwordless sudo for Ansible with the [2nd answer here](https://serverfault.com/questions/160581/how-to-setup-passwordless-sudo-on-linux)
* Create a ~/.bashrc for the `qamaidsafe` user with `export PATH=/usr/local/bin:$PATH`

You should now be able to establish an SSH connection to this slave.

The last step of those instructions is to make `/usr/local/bin` available for non-login shells, which is what Ansible will have. On macOS the environment is very minimal for non-login shells. Previously I was getting around this by symlinking things into `/usr/bin` (which is on the PATH for non-login shells), but Apple's 'System Integrity Protection' now prevents this directory from being written to, even as root. `/usr/local/bin` is where Homebrew installs most things, so we require this to be on `PATH` for non-login shells.

## Building Vagrant Boxes

The Linux Vagrant boxes are based on [publicly available](https://app.vagrantup.com/boxes/search) official base boxes (e.g. [Ubuntu's official boxes](https://app.vagrantup.com/ubuntu)), but there aren't really any official, reliable base boxes for Windows. For that reason, in this repository we construct our own.

Here are the instructions for building the Windows 2012 R2 server box:

* Install [Packer](https://packer.io/) (the latest version should do) on your host.
* Get an evaluation ISO of Windows 2012 R2 from [here](https://www.microsoft.com/en-gb/evalcenter/evaluate-windows-server-2012-r2).
* Clone this repo.
* Put the file in the `iso` directory in this repo (create it if it doesn't exist - it's in the .gitignore to prevent large ISO files being committed).
* Run `make build-base-windows-2012_r2-box`.
* After that's completed, you can add the resulting box for use with Vagrant using `vagrant box add packer_output/windows2012r2min-virtualbox.box`.

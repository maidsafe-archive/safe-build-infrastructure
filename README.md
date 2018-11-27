# Build Infrastructure

This repository houses automated build infrastructure for various Maidsafe projects. The purpose is to provide reproducible build environments for a Jenkins-based system or for developers who need a known configuration for debugging build problems; doing our builds from known configurations reduces the 'it works on my machine' effect.

Right now there are only some VMs available, but hopefully shortly we can provide some Docker containers for running builds in.

## Setup

To get the VMs up and running, you need some things installed on your development host:

* [Vagrant](https://www.vagrantup.com/). Generally just get the latest version for your distro. You can run it on a Linux, Windows or OSX host.
* After installing Vagrant, install a couple of plugins for it:
  - [vagrant-hosts](https://github.com/oscar-stack/vagrant-hosts): `vagrant plugin install vagrant-hosts`.
  - [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest): `vagrant plugin install vagrant-vbguest`.
* [Virtualbox](https://www.virtualbox.org/wiki/Downloads). The list of versions supported by Vagrant is [here](https://www.vagrantup.com/docs/virtualbox/). Sometimes the latest versions aren't supported yet, but generally it's OK to just grab the latest version.
* The easiest way to get machines running are via the convenience targets in the Makefile. Most Linux distros will probably have `make` installed via other packages like `build-essentials`. Google for how to install it on your distro. On Windows you can get access to `make` by installing [MSYS2](http://www.msys2.org/) then running `pacman -S make`; after this add `c:\msys64\usr\bin` to your `PATH` variable to have `make` accessible via `cmd.exe`. On OSX you can install via the [Apple Developer Tools](http://developer.apple.com/) and there's also a package available for [Homebrew](https://formulae.brew.sh/formula/make).
* Get a copy of the Ansible vault password from someone in QA, then put that in `~/.ansible/vault-pass` on the host.

If you want to build the Windows boxes you will need a [Packer](https://packer.io/) installation; however this isn't necessary for running the Vagrant boxes, as the boxes will be hosted on S3.

## VMs

| Name                                | OS              | Description                                                                                                                                                                                                              | Installed Contents                                                                                                                                  |
| ----                                | --              | -----------                                                                                                                                                                                                              | --------                                                                                                                                            |
| ubuntu-trusty-rust_slave            | Ubuntu 14.04    | Use for building Crust on Ubuntu. This version of Ubuntu matches the version in use on Travis, so it should be very similar to their environment.                                                                        | gcc, libssl-dev, pkg-config, musl-dev, musl-tools, rust 1.29.2, x86_64-unknown-linux-musl target, cargo-script                                      |
| centos-7-rust_slave                 | CentOS 7.5      | Use for building Crust on CentOS. Currently it won't build due to a weird issue with openssl.                                                                                                                            | gcc, openssl-devel, musl compiled from source (no packages on available on CentOS), rust 1.29.2, x86_64-unknown-linux-musl target, cargo-script     |
| windows-2012_r2-base                | Windows 2012 R2 | Use as a base box when you need a completely clean machine.                                                                                                                                                              | Only the base operating system.                                                                                                                     |
| windows-2012_r2-msys2-rust_slave    | Windows 2012 R2 | Use for building Crust on Windows. This is setup to use MinGW rather than MSVC.                                                                                                                                          | MSYS2, mingw-w64-x86_64-gcc, rust 1.29.2, ConEmu, Chrome (the last 2 are just for alternatives to the unfortunately poor default tools on Windows). |
| windows-2012_r2-git_bash-rust_slave | Windows 2012 R2 | Use for debugging issues running Windows builds on Travis, which uses Git Bash as a shell. The reason why it's a separate box is because sometimes Git Bash and MSYS2 can interfere with each other.                     | Git Bash, rust 1.29.2, ConEmu, Chrome (the last 2 are just for alternatives to the unfortunately poor default tools on Windows).                    |

The Linux boxes here use the official, publicly available Vagrant base boxes. There aren't really any reliable base boxes available for Windows, so this repo contains a [Packer](https://www.packer.io/intro/) template for building the Windows box.

## Building Vagrant Boxes

The Linux Vagrant boxes are based on [publicly available](https://app.vagrantup.com/boxes/search) official base boxes (e.g. [Ubuntu's official boxes](https://app.vagrantup.com/ubuntu)), but there aren't really any official, reliable base boxes for Windows. For that reason, in this repository we construct our own.

Here are the instructions for building the Windows 2012 R2 server box:

* Install [Packer](https://packer.io/) (the latest version should do) on your host.
* Get an evaluation ISO of Windows 2012 R2 from [here](https://www.microsoft.com/en-gb/evalcenter/evaluate-windows-server-2012-r2).
* Clone this repo.
* Put the file in the `iso` directory in this repo (create it if it doesn't exist - it's in the .gitignore to prevent large ISO files being committed).
* Run `make build-windows-slave`.
* After that's completed, you can add the resulting box for use with Vagrant using `vagrant box add packer_output/windows2012r2min-virtualbox.box`.

## Building Crust

### Build on a VM

These instructions assume a working installation of [Vagrant](https://www.vagrantup.com/). The host could be Windows or OSX, however, on Windows you'd also need an [MSYS2](http://www.msys2.org/) installation to run `make` in a `cmd.exe` environment.

#### Linux

Follow these steps for building [Crust](https://github.com/maidsafe/crust) on Ubuntu 14.04:

* Produce the VM with `make ubuntu-trusty-rust-slave`
* SSH into the VM with `vagrant ssh ubuntu-trusty-rust-slave`
* Switch to the jenkins user with `sudo su - jenkins`
* Get the Crust source with `git clone https://github.com/maidsafe/crust`
* Change the the crust directory with `cd crust` and if applicable change to any relevant branch
* Build the source with `cargo build --example client --release --target x86_64-unknown-linux-musl`
* Run the tests with `cargo test`

#### Windows

Follow these steps for building [Crust](https://github.com/maidsafe/crust) on Windows 2012 R2:

* Produce the VM with `make windows-2012_r2-rust-slave`
* After the VM boots, you should be logged in, but unfortunately you need to log out and log back in as the `vagrant` user (the password is "vagrant") for environment variables to take effect.
* Get the Crust source with `git clone https://github.com/maidsafe/crust`.
* Change the the crust directory with `cd crust` and if applicable change to any relevant branch.
* Build the source with `cargo build --example client --release`.
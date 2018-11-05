# Build Infrastructure

This repository houses automated build infrastructure for various Maidsafe projects. The purpose is to provide reproducible build environments for a Jenkins-based system or for developers who need a known configuration for debugging build problems; doing our builds from known configurations reduces the 'it works on my machine' effect.

Right now there are only some VMs available, but hopefully shortly we can provide some Docker containers for running builds in.

## VMs

| Name                       | OS              | Description                                                                                                                                       | Installed Contents                                                                                                                                  |
| ----                       | --              | -----------                                                                                                                                       | --------                                                                                                                                            |
| ubuntu-trusty-rust-slave   | Ubuntu 14.04    | Use for building Crust on Ubuntu. This version of Ubuntu matches the version in use on Travis, so it should be very similar to their environment. | gcc, libssl-dev, pkg-config, musl-dev, musl-tools, rust 1.29.2, x86_64-unknown-linux-musl target, cargo-script                                      |
| centos-7-rust-slave        | CentOS 7.5      | Use for building Crust on CentOS. Currently it won't build due to a weird issue with openssl.                                                     | gcc, openssl-devel, musl compiled from source (no packages on available on CentOS), rust 1.29.2, x86_64-unknown-linux-musl target, cargo-script     |
| windows-2012_r2-rust-slave | Windows 2012 R2 | Use for building Crust on Windows. This is setup to use MinGW rather than MSVC.                                                                   | MSYS2, mingw-w64-x86_64-gcc, rust 1.29.2, ConEmu, Chrome (the last 2 are just for alternatives to the unfortunately poor default tools on Windows). |

The Linux boxes here use the official, publicly available Vagrant base boxes. There aren't really any reliable base boxes available for Windows, so this repo contains a [Packer](https://www.packer.io/intro/) template for building the Windows box.

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

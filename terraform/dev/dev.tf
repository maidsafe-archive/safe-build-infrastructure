provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "jenkins_dev" {
  key_name = "jenkins-dev"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDW+gx3axoFvvafQX5camHzGGvu+AExYdKOwN3o1aXmbSpBmgmtcY9eQyukId7al9yoTkCIWB2PjBwpmcGBPQIIsEfaw1kD6JhV6a4OxWp9uRbPNMPnJJTZo/c9Vzze7d02zRh8x0zJ1+NsIWxfFr5jXli9xeKeIQV6e5GLrMV0QRRXy+xglrNg9bJdvfw1eBGOwxYh169ug+Mzp2MEtz+PggAMECV37vNX4w6a0ahJrLs5bfDtAZTRvikgJ6w6CQwVidBlY3XAWC+Q4fHe8DvSS6sN8F0U6gjvdXhS/AvuVLnqeZywUCkYkm3gfW0SKyLw8zKJJ6wiEk7NSArdRJpH"
}

resource "aws_key_pair" "windows_slave_dev" {
  key_name = "windows_slave-dev"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDnrsKRFns+kSRbE6dwSKc2OpHer05pw1Xog8Cu9BP6a6jU2McsxlnK1Qh5Dpzqx1XSIKPLF/mAR+S+9yND8bcZZKHG1rxrxbeF7VMsEPW7xZQX7erNAMoga+jYciAYakKYga4qoxWLYbmG9jm2p0O+7WlfQCKQo7inIJZMHk11pkLYqwX5P3MgxAYB218+qMLzsUtm2+AXPNTmDcQ9oIu9zSt197t0TfF/Igz7pNSPOWgZzocCVsTdr35hW86roFjKFuXm85mPtYBgk8n31+WCt63mmUnWcrCH9dF7X1wfYDyzyQ1QszT7DoPLbnQWeHO2zzyXxjytN5CQqmtqsI/B"
}

resource "aws_key_pair" "docker_slave_dev" {
  key_name = "docker_slave-dev"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkKreOrqHVOsvuHR2af52CfzwR/HShejDzuwz+qCq1g2FJWQfvOYlV6U31rJ9QzaSKdUhdLg4O2WQS5Y2D5z36fn/Nwd/bgG7dKl0/1Mb8AELrCa5E3NUl5bEiEEbw5O/KPk/eOygD8LqbkaBTSpC8WpAAdpU4ulElXpVbdCkTh0+YgMOFjrMts8qhFWJ94d3jatW4l2egJlPBVpftTs/4fYfJOaPMqDLFMg0hpiJ1gIItkPrbmAdjERR8Va5C7jpJ8PG+qiO4faWJqjj6hHY8nXSfs1CgGx/dkOF2Cp2E+YR+/xfsydyxc6Fz1gaPBK4JxU3UCbzeZMWNQNa1IrXJ"
}

resource "aws_instance" "jenkins_master" {
  ami = "${lookup(var.jenkins_master_ami, var.region)}"
  instance_type = "${var.jenkins_master_instance_type}"
  key_name = "${var.jenkins_key_pair}"
  subnet_id = "${var.default_subnet_id}"
  associate_public_ip_address = true
  user_data = "${file("../../scripts/sh/setup_ansible_user_dev.sh")}"
  vpc_security_group_ids = [
    "${aws_security_group.jenkins_master.id}"
  ]
  tags {
    Name = "jenkins_master"
    full_name = "jenkins_master-ubuntu-bionic-x86_64"
    group = "masters"
    environment = "dev"
  }
}

resource "aws_instance" "docker_slave" {
  ami = "${lookup(var.docker_slave_ami, var.region)}"
  instance_type = "${var.docker_slave_instance_type}"
  key_name = "${var.jenkins_key_pair}"
  subnet_id = "${var.default_subnet_id}"
  associate_public_ip_address = true
  user_data = "${file("../../scripts/sh/setup_ansible_user_dev.sh")}"
  vpc_security_group_ids = [
    "${aws_security_group.linux_slaves.id}"
  ]
  tags {
    Name = "${format("docker_slave_%03d", count.index + 1)}"
    full_name = "${format("docker_slave_%03d-centos-7.6-x86_64", count.index + 1)}"
    group = "linux_slaves"
    environment = "dev"
  }
  count = 2
}

resource "aws_instance" "windows_slave" {
  ami = "${lookup(var.windows_ami, var.region)}"
  instance_type = "${var.windows_instance_type}"
  key_name = "${var.windows_slave_key_pair}"
  subnet_id = "${var.default_subnet_id}"
  user_data = "${file("../../scripts/ps/setup_winrm.ps1")}"
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${aws_security_group.windows_slaves.id}"
  ]
  tags {
    Name = "${format("windows_slave_%03d", count.index + 1)}"
    full_name = "${format("rust_slave_%03d-windows-2016-x86_64", count.index + 1)}"
    group = "windows_slaves"
    environment = "dev"
  }
  count = "${var.windows_slave_count}"
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "ansible" {
  key_name = "${var.ansible_key_pair}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDbyNTXKxEF7/bTbOA1tj1NB3Ducg9C+4VLyV0yj+NHFOOJ/Ff99a/rQoqSSkH5ltcdGig6wW3ZE96eNnEHXxUtECe4ySiwkni3lEod2x48iX00Tt+/OEgbOOKwUW8Bpj2EujUwhOXGji1e2AaUDE8Y2woOnffchVE7vY0Oxeh6KvTbBh+RFlIJ0eWBTpJGZyiK0kHrgV2DkIABeup6p5vrIoWmZA+oRY8EOO6xIeextchCzIE0hETMdSu1UdVcx8K+vR9OIWolDx5D7wpJ1I46ZJmSmp4V/lDx2MYEaol4f1sbpn/9KQ23RAm22R/z7FwmZJhAUfWRDjmH6n/5xUwx"
}

resource "aws_key_pair" "haproxy" {
  key_name = "${var.haproxy_key_pair}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCn4HZMaCuUpS10sTbpnQO5SDX/CmLagvALAadErs2o0whJOhFV4gr03KNeGUnU2+bD98Ud30YdUNJqE7z/cwNdpZUwHxV05LY5C/w0k50gMMSoCU5FlUBaXpUovmtlINm80nej8I5rCgkcOchfLkDvyREAtxNOv1s/8hVgHwos4H6C6AHMbH+aYIE8VPMERnkchoLVg7j0/2YyTAR9ce5tOCt1v6Bvi2HIXvPj2hhfVwmtfYozHbvpjrhL1pQ/niSs9SRCp2jTK0dGe66E+i8VXHGHMY+jQdUTPkZfrJvu/SGesvz23VAmVTSp/pZPFbLsLKyLJtgexkEzpntVNOxn"
}

resource "aws_key_pair" "jenkins" {
  key_name = "${var.jenkins_key_pair}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQClwZPQlg/WP47+Mo+Sc4wWCNaiV6vPhHsN60GDTTQ+OV4eUcizYOREW3Q0eQEtvbt4LrErtnfqAL0fpHs0cdxEu2CY7+ofj6LB6EHfmLCU26GnMdNrNVphj/a7b5WKFwc+bllY/5IBZPhcbQh1r+7dtj4KrvsyQeFShR4Ng3fwYHOzhgRpj9EpZcG8LUpj1auiQIKPl+va9gePvkiVkzYnh8jeymvQMOpqwu21t70llHcEc2PHN4y07i5EETqAiY5BVxv4Hz4QbT8Ygsj6hz6wTsU07sbLceOPQuT2iOO4+y5gP35//Zh8V7AG/TKhz3auFv00NpBK1oWbum6yRGPT"
}

resource "aws_key_pair" "windows_slave" {
  key_name = "${var.windows_slave_key_pair}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCFVXXxvxBSKeZMMWNHSh1I6JgWTIJVIAjWh/SsONDvlX/8IWSoh1RHbO0KsdZMfgQpHN3qDKOfjLrh+zrOgIpn9Q7QXiDRtFB8zwT/zpNsw2QdrkJ3yvNgglQHE2xLROehotX0Iyjl+oO3f5nNvHM91emF5SGrLzdq6j9bW2rQupM3reEexS0Wy+mBxpcO+2pKIQNbNI3nrjGIq2lHsObRTCE9vpwY3gG6Hl7lzTI04UzeUeUX2X5C3fSbDfmT67gtpMUkG1HIWvn5TPaKFXUBpZMTGjmq21dH7SiSiO3rJKs8qaonEb9gvm7Nt3VlvWZggEwRe0T1UNMqEkXPvEh"
}

resource "aws_key_pair" "windows_bastion" {
  key_name = "${var.windows_bastion_key_pair}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1HAQQe1SYguTcmn6Oqv2ycy+CntG2vO4xBEQlOBpiHUrjhpUvnRP8bzwX7zIl4qbW5PCwVcS55ryHRqaRBzbycTDAgJIbDiErpqTx1D/XnQrXAFBxRwJREhGAaXXAN62KNQzRMtH01X6x9oF1xHjVvqX7snswoZRGY7stLDLqMLaRsuw0yZX9u6Au5XPzClx4cntVGc9Kz9h781C/Yk7L3aJgxg//q8WFP3g/oVtj5dddukNtK2p+TRE3SR5GHA8hv+CTW26s6aEeMEquAKUq5NrDrbh6dmb/qIAiIqqJsW49iq3V5wbFhnb/OM+Av+WDW/n84SZyVjc+cbYWCRsl"
}

resource "aws_key_pair" "docker_slave" {
  key_name = "${var.docker_slave_key_pair}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDD+Lpgpr0QQdp3guno5NCV50Ete/AQvWPmh01XdcojGgmnTWs2ZFcwA2SFhjpWXDFKOKwQ8cWZpRY0Kosuoi32bJV/D/rpNVnMy3R2nD3y790epSRv8qKJgc3rsTPDZeE7FNZbcto2KFD/+arm0h+spSiG8od80r5Ajf+M8B6CKuCAmPIV3E2Ni+XsYtrePsoUYmtS+m7hSwBmNpZLvw2WXXda/D3/maH1kIqErTgrBM5eHiWAfvslaqlRE4xggW86Pzfjq090TGq5vuY7YFT/5mw4MXYwt/i7aStJvuBjU58jlAyK+avoO0+gzlPk3rLXSvvYjRzMVpG04PjSqCYZ"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.59.0"
  name = "${var.subnet_name}"
  cidr = "10.0.0.0/16"
  azs = "${var.availability_zones}"
  public_subnets = ["10.0.0.0/24"]
  private_subnets = ["10.0.1.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support = true
}

data "aws_eip" "jenkins_elastic_ip" {
  id = "${var.jenkins_elastic_ip}"
}

resource "aws_instance" "jenkins_master" {
  ami = "${lookup(var.jenkins_master_ami, var.region)}"
  instance_type = "${var.jenkins_master_instance_type}"
  key_name = "${var.jenkins_key_pair}"
  subnet_id = "${module.vpc.private_subnets[0]}"
  associate_public_ip_address = false
  user_data = "${file("../../scripts/sh/setup_ansible_user_${var.environment_name}.sh")}"
  vpc_security_group_ids = [
    "${aws_security_group.jenkins_master.id}"
  ]
  tags {
    Name = "jenkins_master"
    full_name = "jenkins_master-ubuntu-bionic-x86_64"
    group = "masters"
    environment = "${var.environment_name}"
  }
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = 500
    volume_type = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name = "/dev/sdc"
    volume_size = 50
    volume_type = "gp2"
    delete_on_termination = true
  }
  root_block_device {
    delete_on_termination = true
  }
}

resource "aws_eip_association" "jenkins_master_eip_association" {
  instance_id = "${aws_instance.haproxy.id}"
  allocation_id = "${data.aws_eip.jenkins_elastic_ip.id}"
}

resource "aws_instance" "ansible" {
  ami = "${lookup(var.ansible_ami, var.region)}"
  instance_type = "${var.ansible_instance_type}"
  key_name = "${var.ansible_key_pair}"
  subnet_id = "${module.vpc.public_subnets[0]}"
  associate_public_ip_address = true
  user_data = "${file("../../scripts/sh/setup_ansible_user_${var.environment_name}.sh")}"
  vpc_security_group_ids = [
    "${aws_security_group.ansible.id}"
  ]
  tags {
    Name = "ansible_bastion"
    full_name = "ansible_bastion-centos-7.6-x86_64"
    group = "provisioners"
    environment = "${var.environment_name}"
  }
  root_block_device {
    delete_on_termination = true
  }
}

resource "aws_instance" "haproxy" {
  ami = "${lookup(var.haproxy_ami, var.region)}"
  instance_type = "${var.haproxy_instance_type}"
  key_name = "${var.haproxy_key_pair}"
  subnet_id = "${module.vpc.public_subnets[0]}"
  associate_public_ip_address = true
  user_data = "${file("../../scripts/sh/setup_ansible_user_${var.environment_name}.sh")}"
  vpc_security_group_ids = [
    "${aws_security_group.haproxy.id}"
  ]
  tags {
    Name = "haproxy"
    full_name = "haproxy-ubuntu-bionic-x86_64"
    group = "provisioners"
    environment = "${var.environment_name}"
  }
  root_block_device {
    delete_on_termination = true
  }
}

resource "aws_instance" "windows_slave" {
  ami = "${lookup(var.windows_ami, var.region)}"
  instance_type = "${var.windows_instance_type}"
  key_name = "${var.windows_slave_key_pair}"
  subnet_id = "${module.vpc.private_subnets[0]}"
  associate_public_ip_address = false
  user_data = "${file("../../scripts/ps/setup_winrm.ps1")}"
  vpc_security_group_ids = [
    "${aws_security_group.windows_slaves.id}"
  ]
  tags {
    Name = "${format("windows_slave_%03d", count.index + 1)}"
    full_name = "${format("rust_slave_%03d-windows-2016-x86_64", count.index + 1)}"
    group = "windows_slaves"
    environment = "${var.environment_name}"
  }
  count = "${var.windows_slave_count}"
  root_block_device {
    delete_on_termination = true
  }
}

resource "aws_instance" "windows_bastion" {
  ami = "${lookup(var.windows_ami, var.region)}"
  instance_type = "${var.windows_instance_type}"
  key_name = "${var.windows_bastion_key_pair}"
  subnet_id = "${module.vpc.public_subnets[0]}"
  associate_public_ip_address = true
  user_data = "${file("../../scripts/ps/setup_winrm.ps1")}"
  vpc_security_group_ids = [
    "${aws_security_group.windows_bastion.id}"
  ]
  tags {
    Name = "windows_bastion"
    full_name = "bastion-windows-2016-x86_64"
    group = "provisioners"
    environment = "${var.environment_name}"
  }
  count = "${var.windows_bastion_count}"
  root_block_device {
    delete_on_termination = true
  }
}

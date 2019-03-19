provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.59.0"
  name = "jenkins_environment"
  cidr = "10.0.0.0/16"
  azs = "${var.availability_zones}"
  public_subnets = ["10.0.0.0/24"]
  private_subnets = ["10.0.1.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
}

resource "aws_instance" "jenkins_master" {
  ami = "${lookup(var.jenkins_master_ami, var.region)}"
  instance_type = "${var.jenkins_master_instance_type}"
  key_name = "${var.key_pair}"
  subnet_id = "${module.vpc.public_subnets[0]}"
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${aws_security_group.jenkins_master.id}"
  ]
  tags {
    Name = "jenkins_master"
    full_name = "jenkins_master-ubuntu-bionic-x86_64"
    group = "masters"
    environment = "prod"
  }
}

resource "aws_instance" "docker_slave" {
  ami = "${lookup(var.docker_slave_ami, var.region)}"
  instance_type = "${var.docker_slave_instance_type}"
  key_name = "${var.key_pair}"
  subnet_id = "${module.vpc.private_subnets[0]}"
  associate_public_ip_address = false
  vpc_security_group_ids = [
    "${aws_security_group.linux_slaves.id}"
  ]
  tags {
    Name = "docker_slave_${format("%03d", count.index + 1)}"
    full_name = "docker_slave_${format("%03d", count.index + 1)}-centos-7.5-x86_64"
    group = "slaves"
    environment = "prod"
  }
  count = 2
}

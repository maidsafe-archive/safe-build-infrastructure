provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "jenkins_prod" {
  key_name = "jenkins-prod"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDW+gx3axoFvvafQX5camHzGGvu+AExYdKOwN3o1aXmbSpBmgmtcY9eQyukId7al9yoTkCIWB2PjBwpmcGBPQIIsEfaw1kD6JhV6a4OxWp9uRbPNMPnJJTZo/c9Vzze7d02zRh8x0zJ1+NsIWxfFr5jXli9xeKeIQV6e5GLrMV0QRRXy+xglrNg9bJdvfw1eBGOwxYh169ug+Mzp2MEtz+PggAMECV37vNX4w6a0ahJrLs5bfDtAZTRvikgJ6w6CQwVidBlY3XAWC+Q4fHe8DvSS6sN8F0U6gjvdXhS/AvuVLnqeZywUCkYkm3gfW0SKyLw8zKJJ6wiEk7NSArdRJpH"
}

resource "aws_key_pair" "windows_slave_prod" {
  key_name = "windows_slave-prod"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbqVexd8nzku6hYYHYQMqP2x8JuRU81IbIKkMG8b/g1Er63tXy7w/QFTYSW11dLyjpN1nPzl+/NljxnWs/yFmztEIlBb2vL94Sp8SyQeWgmEHFGCrA9EaneWU6DFQJ8SptMwfE9rBzY5d/ouo90fYopPJYkG4kGcadIWR+g3Fx/t8tQf0T8ogrknWJmaAAsIi+BVINnXYyTmSLOc63ZoA9K1dCOps4YBVNmgxitrrGa+Lo0fB6Aza8m7dfweM7nwSOpSHEsXC/aA85czOd9dWzbaXAEFqAJYzSACubSM55R6telSkJhE6YIZ0p8C+YdZQmQPOweeCSZs31G3sN7pdj"
}

resource "aws_key_pair" "windows_bastion_prod" {
  key_name = "windows_bastion-prod"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTFIv1T40+T+xwuD/2BhO2+jgv/iKQ1qadkE9gm3hGG4xziyqsD2YUZ6+o8o0wfhAuTUDh/p1vXrm6PYJpA6ncYovmEJ6/ZlLDl2XDAoV8gpZAovCjHqIOd1zegE5vQYKl7P5kbdCgDzyKXfUd++C5l3zIY/WQCutUxoEw5m/Wy6ILDnBT0+Y7pmkFGQyzhgVgkqvYbxUQsQXTkuJiGtzlrOlApDY7yeJneN4g3rUzaTg1vUyep6yUfh5IVEXZ69eCIuoXS5wLd38BTAIfCc7lwEcnjmAVMjJqTxV0thvIGNlhwbgxhcrB7U9q9agsGCQBLAsHxE9h9OcRkcllj1qR"
}

resource "aws_key_pair" "docker_slave_prod" {
  key_name = "docker_slave-prod"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDeXRo+ENDr9I8uFQwuRP0cghcjX+6Q8XnmuxWiVEpGakluP3URWr8+bfL4SQ8bqoAFf6Lb/PjpdxWopQoW72N9Mej7Z5Y2+koa1Hh5IaHl+PuzEDnhlm1Y7gYuTj9+ZdhlDzX+98pwPTzdPVpxpz0MEibPe+XEe+TKeBK/3gJO2Gu22HC5yewoy0nShhHcAgBRXrjJJJ9vcuslOv/rTkWqSiFLAvibq869Nl80aP8YQdy0Kwl2wsvDb4qkfEXiW8P2/DwLiNGpr4kY5qQA4Adr83j+NT25kh7LLqWot/vAYwaAwmfZ+y6lAwiC5OXHGtIVF6gA19HGDQkIOx4aqny9"
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
  subnet_id = "${module.vpc.public_subnets[0]}"
  associate_public_ip_address = true
  user_data = "${file("../../scripts/sh/setup_ansible_user_prod.sh")}"
  vpc_security_group_ids = [
    "${aws_security_group.jenkins_master.id}"
  ]
  tags {
    Name = "jenkins_master"
    full_name = "jenkins_master-ubuntu-bionic-x86_64"
    group = "masters"
    environment = "prod"
  }
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = 500
    volume_type = "gp2"
    delete_on_termination = false
  }
  ebs_block_device {
    device_name = "/dev/sdc"
    volume_size = 50
    volume_type = "gp2"
    delete_on_termination = false
  }
}

resource "aws_eip_association" "jenkins_master_eip_association" {
  instance_id = "${aws_instance.jenkins_master.id}"
  allocation_id = "${data.aws_eip.jenkins_elastic_ip.id}"
}

resource "aws_instance" "ansible" {
  ami = "${lookup(var.ansible_ami, var.region)}"
  instance_type = "${var.ansible_instance_type}"
  key_name = "${var.jenkins_key_pair}"
  subnet_id = "${module.vpc.public_subnets[0]}"
  associate_public_ip_address = true
  user_data = "${file("../../scripts/sh/setup_ansible_user_prod.sh")}"
  vpc_security_group_ids = [
    "${aws_security_group.ansible.id}"
  ]
  tags {
    Name = "ansible_bastion"
    full_name = "ansible_bastion-centos-7.6-x86_64"
    group = "provisioners"
    environment = "prod"
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
    Name = "windows_slave_001"
    full_name = "rust_slave-windows-2016-x86_64"
    group = "windows_slaves"
    environment = "prod"
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
    environment = "prod"
  }
  count = "${var.windows_bastion_count}"
}

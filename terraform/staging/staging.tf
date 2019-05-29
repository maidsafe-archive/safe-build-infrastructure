provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "haproxy" {
  key_name = "${var.haproxy_key_pair}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGhjnDd0oh+eNKOvyRY6hA2CIGWztDudLJ0tcdX3bPo3H3caYRSPeuAnruovu6Fnf36AMIJIteoMNx9yZgA+/Y2wVPPE6h4RpW7OOGB0f5GobFPMEfsC3dQcP+OK6PRr5x6zeFhL2cYU69pJCaK8eRd+Q/H8ORbD3LjkCHGyPm3IO3+j4utOmTFHgNZcvHHYecrHqsdd6IlxgCb4vPOrgN+HpCMzz+o+pcgQ1WozReo5gmnVZHXfNQ8TXmWwwZOU8GXeR3MOP6C6nnbMnmm4WmxQOjXuzMdmk7FSvmstjV1M4SN0xdDheIFZjE2YMZ5tIDoPEBxqA/9YMKdNh1ak6V"
}

resource "aws_key_pair" "jenkins" {
  key_name = "${var.jenkins_key_pair}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDW+gx3axoFvvafQX5camHzGGvu+AExYdKOwN3o1aXmbSpBmgmtcY9eQyukId7al9yoTkCIWB2PjBwpmcGBPQIIsEfaw1kD6JhV6a4OxWp9uRbPNMPnJJTZo/c9Vzze7d02zRh8x0zJ1+NsIWxfFr5jXli9xeKeIQV6e5GLrMV0QRRXy+xglrNg9bJdvfw1eBGOwxYh169ug+Mzp2MEtz+PggAMECV37vNX4w6a0ahJrLs5bfDtAZTRvikgJ6w6CQwVidBlY3XAWC+Q4fHe8DvSS6sN8F0U6gjvdXhS/AvuVLnqeZywUCkYkm3gfW0SKyLw8zKJJ6wiEk7NSArdRJpH"
}

resource "aws_key_pair" "windows_slave" {
  key_name = "${var.windows_slave_key_pair}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1IfddK8Eh4flvBXJLjgMZbsvxdUXdkxrAv4bRjqOK7EQ0XqANZBrQ0N3rZx6+zPr6CJ8CK4ER+ZP63LPEOvVPtiBEVrR8c4mrWDx7cOL3/3aEuppmj2ljIAHdOaLhul1pWbPgf6VkuZUr9GBfSHaO3Zt8tm7YNtALZZVOsK0Vp3XpzlFZwCFFAU0llG37RFlr8Mwl6mP4xCyPswJppd2zsIZe8kUYho46SszMNitdfPP6OdhGeoGnBQVxyt2ziZ7EXx0RoawkMnELtX4rDVf9vCW0AeNxhQ7mbtbxuQ9mHXamBJPXO26l8cNkr35b7akNjqYyr17NemeTXixM7tW/"
}

resource "aws_key_pair" "windows_bastion" {
  key_name = "${var.windows_bastion_key_pair}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDT5P9kamSDHy22mWCSZiGUwNP/EhGRZJPobPMitRSgeoEQ5UMGQeJhyUD+lGg3kB1j4eKmSHEtbCpe4Bgse46sl0iYrQ0hqsFIuG+/kpvK8pmS7+uu8Fq0oIC9Fu8imdHjAFcAj2SsWTktw77lmB7meWSKnCIwCy+MIWO3zleC+/gH3iGb1LM1t1Orsp7PZI/itIOMK2wNTwDo/zg92Wr1OLdC0/y7mxh28AASnsMVg4UEhU3n64sk2SJ1xxyVyzZAuhntLkfjUCekiNb1eFc2jUU5xUvKX36YG3dwM80KN29Ds12RULcnO9dqAk2120dQYt8FGKkIIfSHQpWoiqf/"
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
  key_name = "${var.jenkins_key_pair}"
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

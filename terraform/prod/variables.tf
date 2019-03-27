variable "region" {
  default = "eu-west-2"
  description = "The AWS region to use"
}

variable "availability_zones" {
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  description = "The availability zones to use"
}

variable "key_pair" {
  default = "jenkins_env"
  description = "The key pair to use for resources"
}

variable "jenkins_master_ami" {
  default = {
    eu-west-2 = "ami-0883141bc92a74917"
  }
  description = "AMI for Jenkins Master (Ubuntu 18.04)"
}

variable "jenkins_master_instance_type" {
  default = "t2.micro"
  description = "Instance type for Jenkins Master"
}

variable "docker_slave_ami" {
  default = {
    eu-west-2 = "ami-0eab3a90fc693af19"
  }
  description = "AMI for Docker slaves (CentOS 7.6)"
}

variable "docker_slave_instance_type" {
  default = "t2.micro"
  description = "Instance type for Docker slaves"
}

variable "ansible_ami" {
  default = {
    eu-west-2 = "ami-0eab3a90fc693af19"
  }
  description = "AMI for Ansible (CentOS 7.6)"
}

variable "ansible_instance_type" {
  default = "t2.micro"
  description = "Instance type for Ansible machine"
}

variable "windows_ami" {
  default = {
    eu-west-2 = "ami-0186531b707ced2ef"
  }
  description = "AMI for Windows slave (Windows 2016)"
}

variable "windows_instance_type" {
  default = "t3.small"
  description = "Instance type for Windows slave machine"
}

variable "windows_bastion_count" {
  default = 0
  description = "Set this to 1 if you need a Windows Bastion host for debugging problems with the Windows slave in the private subnet."
}

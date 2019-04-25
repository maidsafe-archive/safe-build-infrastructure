variable "region" {
  default = "eu-west-2"
  description = "The AWS region to use"
}

variable "default_vpc_id" {
  default = "vpc-0e247a67fd21cbc4b"
  description = "The ID of the default VPC"
}

variable "default_subnet_id" {
  default = "subnet-0dc8de256c06167e2"
  description = "The ID of the default subnet on the default VPC"
}

variable "availability_zones" {
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  description = "The availability zones to use"
}

variable "key_pair" {
  default = "jenkins-dev"
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

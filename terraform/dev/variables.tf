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

variable "jenkins_key_pair" {
  default = "jenkins-dev"
  description = "The key pair for the Jenkins master"
}

variable "windows_slave_key_pair" {
  default = "windows_slave-dev"
  description = "The key pair for Windows slaves"
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
    eu-west-2 = "ami-0883141bc92a74917"
  }
  description = "AMI for Docker slaves (Ubuntu 18.04)"
}

variable "docker_slave_instance_type" {
  default = "t2.micro"
  description = "Instance type for Docker slaves"
}

variable "windows_ami" {
  default = {
    eu-west-2 = "ami-00d68c7ba3a78073f"
  }
  description = "AMI for Windows slave (Windows 2016)"
}

variable "windows_instance_type" {
  default = "t3.small"
  description = "Instance type for Windows slave machine"
}

variable "windows_slave_count" {
  default = 1
  description = "Determines the number of Windows slaves"
}

variable "docker_slave_count" {
  default = 1
  description = "Determines the number of Windows slaves"
}

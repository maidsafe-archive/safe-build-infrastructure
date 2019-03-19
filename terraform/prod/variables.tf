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

variable "jenkins_env_nat_ami" {
  default = {
    eu-west-2 = "ami-0eab3a90fc693af19"
  }
  description = "AMI for NAT (CentOS 7.6)"
}

variable "jenkins_env_nat_instance_type" {
  default = "t2.micro"
  description = "Instance type for NAT machine"
}

variable "jenkins_env_bastion_ami" {
  default = {
    eu-west-2 = "ami-0eab3a90fc693af19"
  }
  description = "AMI for Bastion (CentOS 7.6)"
}

variable "jenkins_env_bastion_instance_type" {
  default = "t2.micro"
  description = "Instance type for Bastion machine"
}

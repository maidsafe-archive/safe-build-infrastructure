variable "util_slave_ami" {
  default = {
    eu-west-2 = "ami-0883141bc92a74917"
  }
  description = "AMI for util slave (Ubuntu 18.04)"
}

variable "util_slave_instance_type" {
  default = "t3.micro"
  description = "Instance type for util slave machine"
}

variable "util_slave_key_pair" {
  default = "util_slave-prod"
  description = "The key pair for the util slave instance"
}

variable "util_slaves_security_group" {
  default = "util_slaves-prod"
  description = "The key pair for the util slave instance"
}

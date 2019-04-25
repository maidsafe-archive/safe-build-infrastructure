region = "eu-west-2"
availability_zones = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
key_pair = "jenkins-prod"
jenkins_master_ami = { eu-west-2 = "ami-0883141bc92a74917" }
jenkins_master_instance_type = "t2.micro"
docker_slave_ami = { eu-west-2 = "ami-0eab3a90fc693af19" }
docker_slave_instance_type = "t2.micro"
ansible_ami { eu-west-2 = "ami-0eab3a90fc693af19" }
ansible_instance_type = "t2.micro"
windows_ami = { eu-west-2 = "ami-0186531b707ced2ef" }
windows_instance_type = "t3.small"
windows_bastion_count = 1

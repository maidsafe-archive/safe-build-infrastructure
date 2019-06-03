region = "eu-west-2"
availability_zones = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
jenkins_key_pair = "jenkins-staging"
jenkins_master_ami = { eu-west-2 = "ami-0883141bc92a74917" }
jenkins_master_instance_type = "t2.micro"
docker_slave_ami = { eu-west-2 = "ami-0eab3a90fc693af19" }
docker_slave_instance_type = "t2.micro"
ansible_ami { eu-west-2 = "ami-0eab3a90fc693af19" }
ansible_instance_type = "t2.micro"
windows_ami = { eu-west-2 = "ami-00d68c7ba3a78073f" }
windows_instance_type = "t3.small"
windows_bastion_count = 1
windows_slave_key_pair = "windows_slave-staging"
windows_bastion_key_pair = "windows_bastion-staging"

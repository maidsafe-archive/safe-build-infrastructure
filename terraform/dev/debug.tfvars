region = "eu-west-2"
availability_zones = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
jenkins_key_pair = "jenkins-dev"
jenkins_master_ami = { eu-west-2 = "ami-0883141bc92a74917" }
jenkins_master_instance_type = "t2.micro"
docker_slave_ami = { eu-west-2 = "ami-0eab3a90fc693af19" }
docker_slave_instance_type = "t2.micro"
windows_ami = { eu-west-2 = "ami-0103bbc73d58441f9" }
windows_instance_type = "t3.small"
windows_slave_key_pair = "windows_slave-dev"

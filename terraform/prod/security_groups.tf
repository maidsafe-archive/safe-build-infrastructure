/*
  Any machines in the Linux slaves group will have SSH access from the Jenkins master, and
  because this is a private subnet, egress HTTP and HTTPS rules allow these instances to have
  internet connectivity via the NAT gateway, for installing updates and so on.
*/
resource "aws_security_group" "linux_slaves" {
  name = "linux_slaves"
  description = "Connectivity for Linux slaves."
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "linux_slaves_ingress_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.jenkins_master.id}"
  security_group_id = "${aws_security_group.linux_slaves.id}"
}

resource "aws_security_group_rule" "linux_slaves_egress_http" {
  type = "egress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.linux_slaves.id}"
}

resource "aws_security_group_rule" "linux_slaves_egress_https" {
  type = "egress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.linux_slaves.id}"
}

resource "aws_security_group_rule" "linux_slaves_egress_ssh" {
  type = "egress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.linux_slaves.id}"
}

/*
  The Jenkins master group is for machines on the public subnet. Right now

  It enables inbound access for HTTP, HTTPs and SSH, but the SSH access should be removed
  in favour of using a Bastion host. The 'all traffic' rules are what enables communication
  between the public and private subnets.
*/
resource "aws_security_group" "jenkins_master" {
  name = "jenkins_master"
  description = "Connectivity for the Jenkins master."
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "jenkins_master_ingress_http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "jenkins_master_ingress_https" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

// Direct SSH access to the Jenkins master should eventually be removed in favour of a Bastion host.
resource "aws_security_group_rule" "jenkins_master_ingress_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "jenkins_master_ingress_all_db_server_traffic" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id = "${aws_security_group.linux_slaves.id}"
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "jenkins_master_egress_http" {
  type = "egress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "jenkins_master_egress_https" {
  type = "egress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "jenkins_master_egress_all_db_server_traffic" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id = "${aws_security_group.linux_slaves.id}"
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group" "linux_slaves" {
  name = "${var.linux_slaves_security_group}"
  description = "Connectivity for Linux slaves."
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "linux_slaves_ingress_ssh_from_jenkins_master" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.jenkins_master.id}"
  security_group_id = "${aws_security_group.linux_slaves.id}"
}

resource "aws_security_group_rule" "linux_slaves_ingress_ssh_from_ansible" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.ansible.id}"
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

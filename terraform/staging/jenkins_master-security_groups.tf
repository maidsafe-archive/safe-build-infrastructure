resource "aws_security_group" "jenkins_master" {
  name = "${var.jenkins_security_group}"
  description = "Connectivity for the Jenkins master."
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "jenkins_master_ingress_ssh_from_util_slave" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.util_slaves.id}"
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

# This rule is necessary for WireGuard to work correctly. If it's not enabled
# the Jenkins Master machine can't contact the correct port and the whole network
# doesn't seem to work correctly.
resource "aws_security_group_rule" "jenkins_master_egress_51820" {
  type = "egress"
  from_port = 51820
  to_port = 51820
  protocol = "udp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "jenkins_master_ingress_ssh_from_ansible" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.ansible.id}"
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "jenkins_master_ingress_http_from_haproxy" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.haproxy.id}"
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "jenkins_master_ingress_50000" {
  type = "ingress"
  from_port = 50000
  to_port = 50000
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
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

// The following 4 rules establish connectivity between the public and private subnets
// for the Jenkins master and the Linux/Windows slaves.
resource "aws_security_group_rule" "jenkins_master_egress_all_linux_slave_traffic" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id = "${aws_security_group.linux_slaves.id}"
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "jenkins_master_ingress_all_linux_slave_traffic" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id = "${aws_security_group.linux_slaves.id}"
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "jenkins_master_egress_all_windows_slave_traffic" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id = "${aws_security_group.windows_slaves.id}"
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "jenkins_master_ingress_all_windows_slave_traffic" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id = "${aws_security_group.windows_slaves.id}"
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

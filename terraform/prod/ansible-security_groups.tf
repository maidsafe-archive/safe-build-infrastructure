/*
  The Ansible group needs to have SSH inbound and the connectivity with the
  private subnet for provisioning all the machines.
*/
resource "aws_security_group" "ansible" {
  name = "${var.ansible_security_group}"
  description = "Connectivity for Ansible machine."
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "ansible_ingress_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ansible.id}"
}

resource "aws_security_group_rule" "ansible_egress_all_linux_slave_traffic" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id = "${aws_security_group.linux_slaves.id}"
  security_group_id = "${aws_security_group.ansible.id}"
}

resource "aws_security_group_rule" "ansible_ingress_all_linux_slave_traffic" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id = "${aws_security_group.linux_slaves.id}"
  security_group_id = "${aws_security_group.ansible.id}"
}

resource "aws_security_group_rule" "ansible_egress_all_jenkins_master_traffic" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id = "${aws_security_group.jenkins_master.id}"
  security_group_id = "${aws_security_group.ansible.id}"
}

resource "aws_security_group_rule" "ansible_ingress_all_jenkins_master_traffic" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id = "${aws_security_group.jenkins_master.id}"
  security_group_id = "${aws_security_group.ansible.id}"
}

resource "aws_security_group_rule" "ansible_egress_all_windows_slave_traffic" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id = "${aws_security_group.windows_slaves.id}"
  security_group_id = "${aws_security_group.ansible.id}"
}

resource "aws_security_group_rule" "ansible_ingress_all_windows_slave_traffic" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id = "${aws_security_group.windows_slaves.id}"
  security_group_id = "${aws_security_group.ansible.id}"
}

resource "aws_security_group_rule" "ansible_egress_http" {
  type = "egress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ansible.id}"
}

resource "aws_security_group_rule" "ansible_egress_https" {
  type = "egress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ansible.id}"
}

resource "aws_security_group_rule" "ansible_egress_ssh_util_slave_traffic" {
  type = "egress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.util_slaves.id}"
  security_group_id = "${aws_security_group.ansible.id}"
}

resource "aws_security_group_rule" "ansible_egress_ssh_to_haproxy" {
  type = "egress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.haproxy.id}"
  security_group_id = "${aws_security_group.ansible.id}"
}

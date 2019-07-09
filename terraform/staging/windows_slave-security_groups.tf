resource "aws_security_group_rule" "windows_slaves_ingress_winrm_from_util_slave" {
  type = "ingress"
  from_port = 5985
  to_port = 5986
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.util_slaves.id}"
  security_group_id = "${aws_security_group.windows_slaves.id}"
}

resource "aws_security_group" "windows_slaves" {
  name = "${var.windows_slaves_security_group}"
  description = "Connectivity for Windows slaves."
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "windows_slave_ingress_from_ansible_winrm" {
  type = "ingress"
  from_port = 5985
  to_port = 5986
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.ansible.id}"
  security_group_id = "${aws_security_group.windows_slaves.id}"
}

resource "aws_security_group_rule" "windows_slave_ingress_rdp" {
  type = "ingress"
  from_port = 3389
  to_port = 3389
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.windows_slaves.id}"
}

resource "aws_security_group_rule" "windows_slaves_egress_http" {
  type = "egress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.windows_slaves.id}"
}

resource "aws_security_group_rule" "windows_slaves_egress_50000" {
  type = "egress"
  from_port = 50000
  to_port = 50000
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.windows_slaves.id}"
}

resource "aws_security_group_rule" "windows_slaves_egress_https" {
  type = "egress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.windows_slaves.id}"
}

resource "aws_security_group" "windows_bastion" {
  name = "${var.windows_bastion_security_group}"
  description = "Connectivity for Windows Bastion host."
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "windows_bastion_ingress_rdp" {
  type = "ingress"
  from_port = 3389
  to_port = 3389
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.windows_bastion.id}"
}

resource "aws_security_group_rule" "windows_bastion_egress_http" {
  type = "egress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.windows_bastion.id}"
}

resource "aws_security_group_rule" "windows_bastion_egress_https" {
  type = "egress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.windows_bastion.id}"
}

resource "aws_security_group_rule" "windows_bastion_egress_all_windows_slave_traffic" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id = "${aws_security_group.windows_slaves.id}"
  security_group_id = "${aws_security_group.windows_bastion.id}"
}

resource "aws_security_group_rule" "windows_bastion_ingress_all_windows_slave_traffic" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id = "${aws_security_group.windows_slaves.id}"
  security_group_id = "${aws_security_group.windows_bastion.id}"
}

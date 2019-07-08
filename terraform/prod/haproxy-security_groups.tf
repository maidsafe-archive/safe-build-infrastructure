resource "aws_security_group" "haproxy" {
  name = "${var.haproxy_security_group}"
  description = "Connectivity for HAProxy."
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "haproxy_ingress_51820" {
  type = "ingress"
  from_port = 51820
  to_port = 51820
  protocol = "udp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.haproxy.id}"
}

resource "aws_security_group_rule" "haproxy_ingress_http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.haproxy.id}"
}

resource "aws_security_group_rule" "haproxy_ingress_https" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.haproxy.id}"
}

resource "aws_security_group_rule" "haproxy_egress_http" {
  type = "egress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.haproxy.id}"
}

resource "aws_security_group_rule" "haproxy_egress_https" {
  type = "egress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.haproxy.id}"
}

resource "aws_security_group_rule" "haproxy_ingress_ssh_from_ansible" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.ansible.id}"
  security_group_id = "${aws_security_group.haproxy.id}"
}

resource "aws_security_group_rule" "haproxy_ingress_ssh_from_util_slave" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.util_slaves.id}"
  security_group_id = "${aws_security_group.haproxy.id}"
}

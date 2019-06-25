resource "aws_key_pair" "util_slave" {
  key_name = "${var.util_slave_key_pair}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDskM5OJ65YIsKIAfJ+zIBr3OTtojl6c379q0EiL86niF9nJqp0OF4WeUm8ZjncUIbnNWrpmK0IRpiC2aFCogOUm0Rorx99a+S3hMyGEjSD5L0he+ZKuGfSUMyisUdW+f/40UxTD/FJkLZXtmmZc3e6ZTqKtu707yqK+vHNjIAPrutgEcaGrBwg+kxRB1E411rX05vJ/CLbIyKRUBfe5lYMwjbtUQ3N9HuMNvZNG5EAoCE8igDw5k85hftfOK/eZXtHe1on6FChKktKJ60odCFW7+/Ul8+5Du6RPhJM4yM5m2tLaDkYygZYzX6VK4HUJHr6KnTi1oH1LCN0n3/iyo+j"
}

resource "aws_security_group" "util_slaves" {
  name = "${var.util_slaves_security_group}"
  description = "Connectivity for util slaves."
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "util_slaves_ingress_ssh_from_ansible" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.ansible.id}"
  security_group_id = "${aws_security_group.util_slaves.id}"
}

resource "aws_security_group_rule" "util_slaves_ingress_ssh_from_jenkins_master" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.jenkins_master.id}"
  security_group_id = "${aws_security_group.util_slaves.id}"
}

resource "aws_security_group_rule" "util_slaves_egress_http" {
  type = "egress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.util_slaves.id}"
}

resource "aws_security_group_rule" "util_slaves_egress_https" {
  type = "egress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.util_slaves.id}"
}

resource "aws_security_group_rule" "util_slaves_egress_ssh_to_jenkins_master" {
  type = "egress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.jenkins_master.id}"
  security_group_id = "${aws_security_group.util_slaves.id}"
}

resource "aws_security_group_rule" "util_slaves_egress_winrm_to_windows_slaves" {
  type = "egress"
  from_port = 5985
  to_port = 5986
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.windows_slaves.id}"
  security_group_id = "${aws_security_group.util_slaves.id}"
}

resource "aws_security_group_rule" "util_slaves_egress_ssh_to_haproxy" {
  type = "egress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.haproxy.id}"
  security_group_id = "${aws_security_group.util_slaves.id}"
}

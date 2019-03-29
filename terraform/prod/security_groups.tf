/*
  Any machines in the Linux slaves group will have SSH access from the Jenkins master, and
  because this is a private subnet, egress HTTP and HTTPS rules allow these instances to have
  internet connectivity via the NAT gateway, for installing updates and so on.
*/
resource "aws_security_group" "linux_slaves-prod" {
  name = "linux_slaves"
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

/*
  The Jenkins master group is for machines on the public subnet. Right now

  It enables inbound access for HTTP, HTTPs and SSH, but the SSH access should be removed
  in favour of using a Bastion host. The 'all traffic' rules are what enables communication
  between the public and private subnets.
*/
resource "aws_security_group" "jenkins_master-prod" {
  name = "jenkins_master"
  description = "Connectivity for the Jenkins master."
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "jenkins_master_ingress_ssh_from_ansible" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.ansible.id}"
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "jenkins_master_ingress_http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "jenkins_master_ingress_8080" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_security_group_rule" "jenkins_master_ingress_https" {
  type = "ingress"
  from_port = 443
  to_port = 443
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

/*
  The Ansible group needs to have SSH inbound and the connectivity with the
  private subnet for provisioning all the machines.
*/
resource "aws_security_group" "ansible-prod" {
  name = "ansible"
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

// The following 6 rules establish connectivity between the public and private subnets
// for the Ansible provisioner and the Linux/Windows slaves.
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

resource "aws_security_group" "windows_slaves-prod" {
  name = "windows_slaves"
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

resource "aws_security_group_rule" "windows_slaves_egress_8080" {
  type = "egress"
  from_port = 8080
  to_port = 8080
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

resource "aws_security_group" "windows_bastion" {
  name = "windows_bastion"
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

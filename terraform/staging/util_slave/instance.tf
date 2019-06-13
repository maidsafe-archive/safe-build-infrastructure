resource "aws_instance" "util_slave" {
  ami = "${lookup(var.util_slave_ami, var.region)}"
  instance_type = "${var.util_slave_instance_type}"
  key_name = "${var.util_slave_key_pair}"
  subnet_id = "${module.vpc.private_subnets[0]}"
  associate_public_ip_address = true
  user_data = "${file("../../scripts/sh/setup_ansible_user_${var.environment_name}.sh")}"
  vpc_security_group_ids = [
    "${aws_security_group.util_slaves.id}"
  ]
  tags {
    Name = "${format("util_slave_%03d", count.index + 1)}"
    full_name = "${format("util_slave_%03d-ubuntu-bionic-x86_64", count.index + 1)}"
    group = "util_slaves"
    environment = "${var.environment_name}"
  }
  root_block_device {
    delete_on_termination = true
  }
}

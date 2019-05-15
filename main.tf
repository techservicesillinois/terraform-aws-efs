locals {
  subnet_id = "${element(data.aws_subnet_ids.selected.ids, 0)}"
  vpc_id    = "${data.aws_vpc.selected.id}"
}

data "aws_vpc" "selected" {
  tags {
    Name = "${var.aws_vpc}"
  }
}

data "aws_subnet_ids" "selected" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags {
    Tier = "${var.tier}"
  }
}

data "aws_security_groups" "selected" {
  count = "${length(var.security_groups) > 0 ? 1 : 0}"

  filter {
    name   = "group-name"
    values = ["${var.security_groups}"]
  }
}

data "aws_ami" "default" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami_name_filter}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["${var.ami_virtualization_type_filter}"]
  }

  owners = ["${var.ami_image_owner}"]
}

resource "aws_instance" "default" {
  ami                         = "${data.aws_ami.default.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${concat(list(aws_security_group.default.id), flatten(data.aws_security_groups.selected.*.ids))}"]
  subnet_id                   = "${local.subnet_id}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  user_data                   = "${file(var.template_file)}"
  tags                        = "${merge(map("Name", var.name), var.tags)}"
}

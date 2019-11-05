locals {
  subnet_ids = distinct(flatten(data.aws_subnet_ids.selected.*.ids))
}

data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc
  }
}

data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Tier = var.tier
  }
}

resource "aws_efs_file_system" "default" {
  encrypted        = var.encrypted
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode
  tags             = merge({ "Name" = var.name }, var.tags)

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_efs_mount_target" "default" {
  count           = length(local.subnet_ids)
  file_system_id  = aws_efs_file_system.default.id
  security_groups = [aws_security_group.default.id]
  subnet_id       = element(local.subnet_ids, count.index)
}

locals {
  subnet_ids = distinct(flatten(data.aws_subnet_ids.selected.*.ids))
}

data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc
  }
}

# Get subnet IDs of each subnet in selected tier.

data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Tier = var.tier
  }
}

# Get details about each subnet ID previously selected.

data "aws_subnet" "selected" {
  for_each = data.aws_subnet_ids.selected.ids
  vpc_id   = data.aws_vpc.selected.id
  id       = each.key
}

# Build a map using the AZ as key, and subnet ID as value.

locals {
  subnets = {
    for id, subnet in data.aws_subnet.selected : subnet.availability_zone => id
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
  for_each        = local.subnets
  file_system_id  = aws_efs_file_system.default.id
  security_groups = [aws_security_group.default.id]
  subnet_id       = each.value
}

module "get-subnets" {
  source = "github.com/techservicesillinois/terraform-aws-util//modules/get-subnets?ref=v3.0.4"

  include_subnets_by_az = true
  subnet_type           = var.subnet_type
  vpc                   = var.vpc
}

# Build map used in for_each clause in the definition for each
# aws_efs_mount_target resource (one per AZ). The map consists of
# the AZ name as key; the value stored under each key is a single
# subnet ID name.
#
# NOTE: this locals block does NOT support the rare use case
# wherein >1 subnets are defined in any AZ.

locals {
  subnets = {
    for az, id in module.get-subnets.subnets_by_az : az => id[0]
  }
}

resource "aws_efs_file_system" "default" {
  encrypted        = var.encrypted
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode
  tags             = merge({ "Name" = var.name }, var.tags)

  # Protect against destruction of persistent resource.

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_efs_mount_target" "default" {
  for_each = local.subnets

  file_system_id  = aws_efs_file_system.default.id
  security_groups = [aws_security_group.default.id]
  subnet_id       = each.value
}

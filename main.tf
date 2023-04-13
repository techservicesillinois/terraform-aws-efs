module "get-subnets" {
  source = "github.com/techservicesillinois/terraform-aws-util//modules/get-subnets?ref=v3.0.4"

  include_subnets_by_az = true
  subnet_type           = var.subnet_type
  vpc                   = var.vpc
}

# NOTE: this locals block does NOT support the rare use case
# wherein >1 subnets are defined in any AZ.

locals {
  # The enis list is used to apply tags to each mount target's ENI.
  # Each list entry consists of a map with the availability zone name,
  # tag key, and tag value as attributes.

  enis = flatten([
    for az, id in local.subnets : [
      for key, value in local.tags : {
        az    = az
        key   = key
        value = value
      }
    ]
  ])

  # The subnets map is used to create one aws_efs_mount_target resource
  # per availability zone. Each map entry uses the availability zone name
  # as key. The value stored under each key is the corresponding ssubnet
  # ID name.
  subnets = { for az, id in module.get-subnets.subnets_by_az : az => id[0] }

  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_efs_file_system" "default" {
  encrypted        = var.encrypted
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode
  tags             = local.tags

  # Protect against destruction of persistent resource.

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_efs_mount_target" "default" {
  file_system_id  = aws_efs_file_system.default.id
  security_groups = [aws_security_group.default.id]

  for_each  = local.subnets
  subnet_id = each.value
}

# Add tags to elastic network interface.

resource "aws_ec2_tag" "default" {
  for_each = { for t in local.enis : (format("eni:%s:%s", t.az, t.key)) => t }

  resource_id = aws_efs_mount_target.default[each.value.az].network_interface_id
  key         = each.value.key
  value       = each.value.value
}

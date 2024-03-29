resource "aws_security_group" "default" {
  description = "EFS ${var.name} server security group"
  name        = "efs-${var.name}-server"
  tags        = local.tags
  vpc_id      = module.get-subnets.vpc.id
}

resource "aws_security_group" "client" {
  description = "EFS ${var.name} client security group"
  name        = "efs-${var.name}-clients"
  tags        = local.tags
  vpc_id      = module.get-subnets.vpc.id
}

resource "aws_security_group_rule" "client_out" {
  description = "Allow outbound connections to efs-${var.name}"

  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.default.id

  security_group_id = aws_security_group.client.id
}

resource "aws_security_group_rule" "in" {
  description = "Allow inbound TCP connections to efs-${var.name}"

  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.client.id

  security_group_id = aws_security_group.default.id
}

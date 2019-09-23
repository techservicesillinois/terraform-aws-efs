output "arn" {
  value = aws_efs_file_system.default.arn
}

output "id" {
  value = aws_efs_file_system.default.id
}

output "dns_name" {
  value = aws_efs_file_system.default.dns_name
}

output "mount_target_ids" {
  value = aws_efs_mount_target.default.*.id
}

output "client_security_group" {
  value = aws_security_group.client.name
}

output "server_security_group" {
  value = aws_security_group.default.name
}


output "security_group_ids" {
  description = "Map of security group names to IDs"
  value       = { for k, v in aws_security_group.this : k => v.id }
}

output "security_group_names" {
  description = "Map of security group names"
  value       = { for k, v in aws_security_group.this : k => v.name }
}

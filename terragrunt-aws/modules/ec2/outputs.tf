output "instance_ids" {
  description = "Map of instance names to IDs"
  value       = { for k, v in aws_instance.this : k => v.id }
}

output "instance_private_ips" {
  description = "Map of instance names to private IPs"
  value       = { for k, v in aws_instance.this : k => v.private_ip }
}

output "instance_public_ips" {
  description = "Map of instance names to public IPs"
  value       = { for k, v in aws_instance.this : k => v.public_ip }
}

output "ssh_private_key" {
  description = "Private SSH key for EC2 access"
  value       = anytrue([for k, v in var.instances : lookup(v, "create_ssh_key", true)]) ? tls_private_key.this[0].private_key_pem : null
  sensitive   = true
}

output "ssh_key_name" {
  description = "Name of the SSH key pair"
  value       = anytrue([for k, v in var.instances : lookup(v, "create_ssh_key", true)]) ? aws_key_pair.this[0].key_name : null
}

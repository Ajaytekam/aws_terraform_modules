output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_nacl_id" {
  description = "ID of the Public Network ACL"
  value       = aws_network_acl.public.id
}

output "private_nacl_id" {
  description = "ID of the Private Network ACL"
  value       = aws_network_acl.private.id
}

output "baseline_security_group_id" {
  description = "ID of the baseline security group for internal communication"
  value       = aws_security_group.baseline.id
}

output "default_security_group_id" {
  description = "ID of the locked-down default security group"
  value       = aws_default_security_group.default.id
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.this.id
}

output "private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "key_name" {
  description = "The name of the key pair attached to the instance"
  value       = local.key_name
}

output "private_key_pem" {
  description = "The generated private key in PEM format (only available when create_key_pair = true)"
  value       = try(tls_private_key.this[0].private_key_pem, null)
  sensitive   = true
}

output "private_key_openssh" {
  description = "The generated private key in OpenSSH format (only available when create_key_pair = true)"
  value       = try(tls_private_key.this[0].private_key_openssh, null)
  sensitive   = true
}

output "ami_id" {
  description = "The AMI ID used for the EC2 instance"
  value       = local.ami_id
}

output "ami_architecture" {
  description = "The architecture of the selected AMI"
  value       = local.arch_normalized
}

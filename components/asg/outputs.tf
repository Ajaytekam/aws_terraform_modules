output "asg_id" { value = aws_autoscaling_group.this.id }
output "asg_name" { value = aws_autoscaling_group.this.name }
output "asg_security_group_id" { value = aws_security_group.asg.id }
output "ami_id" {
  description = "The AMI ID used for the launch template"
  value       = local.ami_id
}
output "ami_architecture" {
  description = "The architecture of the selected AMI"
  value       = local.arch_normalized
}

output "user_names" {
  description = "List of created IAM user names"
  value       = [for u in aws_iam_user.this : u.name]
}

output "user_arns" {
  description = "Map of username to ARN"
  value       = { for u in aws_iam_user.this : u.name => u.arn }
}

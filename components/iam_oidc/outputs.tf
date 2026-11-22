output "role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "role_name" {
  description = "Name of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions.name
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider (either newly created, reused from existing, or default)"
  value       = local.oidc_provider_arn
}

output "oidc_provider_created" {
  description = "Whether the OIDC provider was created by this module (false if reused or already existed)"
  value       = local.should_create_provider
}

output "oidc_provider_already_existed" {
  description = "Whether the OIDC provider was detected as already existing in the AWS account"
  value       = local.provider_already_exists
}

output "sub_conditions" {
  description = "The sub claim patterns allowed to assume the role"
  value       = local.sub_conditions
}

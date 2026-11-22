terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

data "aws_caller_identity" "current" {}

# 1. Fetch GitHub's OIDC TLS Certificate Thumbprint dynamically
data "tls_certificate" "github" {
  count = var.create_oidc_provider ? 1 : 0
  url   = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# 2. Register GitHub as an OIDC Identity Provider in AWS IAM (if not already existing)
resource "aws_iam_openid_connect_provider" "github" {
  count           = var.create_oidc_provider ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github[0].certificates[0].sha1_fingerprint]
  tags            = var.tags
}

locals {
  # Resolve OIDC Provider ARN (either newly created or existing)
  default_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
  oidc_provider_arn    = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : (var.existing_oidc_provider_arn != null ? var.existing_oidc_provider_arn : local.default_provider_arn)

  # Parse repository owner and name (handles owner/repo format)
  repo_split = length(split("/", var.repository)) == 2 ? split("/", var.repository) : [var.repository, ""]
  repo_owner = local.repo_split[0]
  repo_name  = local.repo_split[1]

  # Generate sub claim patterns with wildcards around names to support both standard and @id formats
  computed_sub_conditions = var.repository != "" ? [
    for branch in var.branches : (
      branch == "*" ? "repo:${local.repo_owner}/${local.repo_name}:*" : "repo:${local.repo_owner}/${local.repo_name}:ref:refs/heads/${branch}"
    )
  ] : []

  # Final sub conditions list
  sub_conditions = length(var.sub_patterns) > 0 ? var.sub_patterns : local.computed_sub_conditions
}

# 3. Create IAM Role with scoped Trust Policy
resource "aws_iam_role" "github_actions" {
  name                 = var.role_name
  description          = var.role_description
  max_session_duration = var.max_session_duration
  tags                 = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = local.sub_conditions
          }
        }
      }
    ]
  })
}

# 4. Attach Managed Policies to Role
resource "aws_iam_role_policy_attachment" "managed" {
  count      = length(var.policy_arns)
  role       = aws_iam_role.github_actions.name
  policy_arn = var.policy_arns[count.index]
}

# 5. Attach optional custom inline policy
resource "aws_iam_role_policy" "custom" {
  count  = var.custom_role_policy_json != null ? 1 : 0
  name   = "${var.role_name}-inline-policy"
  role   = aws_iam_role.github_actions.id
  policy = var.custom_role_policy_json
}

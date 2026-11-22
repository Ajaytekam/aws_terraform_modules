terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    tls = {
      source = "hashicorp/tls"
    }
    external = {
      source = "hashicorp/external"
    }
  }
}

data "aws_caller_identity" "current" {}

# 1. Dynamically check if GitHub OIDC provider already exists in this AWS account
data "external" "check_provider" {
  count   = var.create_oidc_provider && var.check_existing_provider ? 1 : 0
  program = ["python3", "${path.module}/check_provider.py"]

  query = {
    account_id = data.aws_caller_identity.current.account_id
  }
}

locals {
  # Determine whether the provider already exists in the account
  provider_already_exists = (
    var.create_oidc_provider && var.check_existing_provider
    ? try(data.external.check_provider[0].result["exists"] == "true", false)
    : false
  )

  # Only create the provider if requested AND it does not already exist
  should_create_provider = var.create_oidc_provider && !local.provider_already_exists

  # Resolve default predictable OIDC Provider ARN
  default_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"

  # Resolve OIDC Provider ARN (from newly created resource, external check, explicit override, or default)
  oidc_provider_arn = (
    local.should_create_provider
    ? aws_iam_openid_connect_provider.github[0].arn
    : (
      var.existing_oidc_provider_arn != null
      ? var.existing_oidc_provider_arn
      : (
        local.provider_already_exists
        ? data.external.check_provider[0].result["arn"]
        : local.default_provider_arn
      )
    )
  )

  # Parse repository owner and name (handles owner/repo format)
  repo_split = length(split("/", var.repository)) == 2 ? split("/", var.repository) : [var.repository, ""]
  repo_owner = local.repo_split[0]
  repo_name  = local.repo_split[1]

  # Generate sub claim patterns with wildcards around names to support both standard and @id formats
  computed_sub_conditions = var.repository != "" ? [
    for branch in var.branches : (
      branch == "*" ? "repo:${local.repo_owner}*/${local.repo_name}*:*" : "repo:${local.repo_owner}*/${local.repo_name}*:ref:refs/heads/${branch}"
    )
  ] : []

  # Final sub conditions list
  sub_conditions = length(var.sub_patterns) > 0 ? var.sub_patterns : local.computed_sub_conditions
}

# 2. Fetch GitHub's OIDC TLS Certificate Thumbprint dynamically (only if creating provider)
data "tls_certificate" "github" {
  count = local.should_create_provider ? 1 : 0
  url   = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# 3. Register GitHub as an OIDC Identity Provider in AWS IAM (only if not already existing)
resource "aws_iam_openid_connect_provider" "github" {
  count           = local.should_create_provider ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github[0].certificates[0].sha1_fingerprint]
  tags            = var.tags
}

# 4. Create IAM Role with scoped Trust Policy
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

# 5. Attach Managed Policies to Role
resource "aws_iam_role_policy_attachment" "managed" {
  count      = length(var.policy_arns)
  role       = aws_iam_role.github_actions.name
  policy_arn = var.policy_arns[count.index]
}

# 6. Attach optional custom inline policy
resource "aws_iam_role_policy" "custom" {
  count  = var.custom_role_policy_json != null ? 1 : 0
  name   = "${var.role_name}-inline-policy"
  role   = aws_iam_role.github_actions.id
  policy = var.custom_role_policy_json
}

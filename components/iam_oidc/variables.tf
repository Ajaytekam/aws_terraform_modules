variable "create_oidc_provider" {
  description = "Whether to create the GitHub OIDC provider. Set to false if it already exists in your AWS account."
  type        = bool
  default     = true
}

variable "check_existing_provider" {
  description = "Whether to automatically check if the GitHub OIDC provider already exists in AWS IAM before attempting creation. If found, skips provider creation and reuses the existing one without error."
  type        = bool
  default     = true
}

variable "existing_oidc_provider_arn" {
  description = "ARN of an existing GitHub OIDC provider. Used if create_oidc_provider is false or provider already exists. If omitted, constructed automatically."
  type        = string
  default     = null
}

variable "role_name" {
  description = "Name of the IAM Role for GitHub Actions"
  type        = string
  default     = "github-actions-deploy-role"
}

variable "role_description" {
  description = "Description of the IAM Role"
  type        = string
  default     = "IAM role assumed by GitHub Actions via OIDC"
}

variable "repository" {
  description = "GitHub repository in 'owner/repo' format (e.g., 'Ajaytekam/aws_terraform_modules')"
  type        = string
  default     = ""
}

variable "branches" {
  description = "List of branches allowed to assume this role (e.g., ['main', 'develop'] or ['*'] for all branches)"
  type        = list(string)
  default     = ["main"]
}

variable "sub_patterns" {
  description = "Custom list of exact sub claim patterns (e.g., ['repo:Owner@id/Repo@id:*']). If provided, overrides repository and branches."
  type        = list(string)
  default     = []
}

variable "policy_arns" {
  description = "List of IAM Managed Policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "custom_role_policy_json" {
  description = "Optional inline IAM policy JSON to attach to the role"
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds (between 3600 and 43200)"
  type        = number
  default     = 3600
}

variable "tags" {
  description = "Tags to attach to the IAM role and OIDC provider"
  type        = map(string)
  default     = {}
}

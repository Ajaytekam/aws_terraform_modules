variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
}

variable "policy_description" {
  description = "Description of the IAM policy"
  type        = string
  default     = "Managed by Terraform"
}

variable "statements" {
  description = "List of statements with optional condition blocks"
  type = list(object({
    sid       = optional(string)
    effect    = optional(string, "Allow")
    actions   = list(string)
    resources = optional(list(string), ["*"])
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
}

variable "tags" {
  description = "Tags to attach to the policy"
  type        = map(string)
  default     = {}
}

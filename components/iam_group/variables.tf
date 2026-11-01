variable "group_name" {
  description = "Name of the IAM group"
  type        = string
}

variable "policy_arns" {
  description = "List of policy ARNs to attach to the group"
  type        = list(string)
  default     = []
}

variable "members" {
  description = "List of IAM usernames to add to this group"
  type        = list(string)
  default     = []
}

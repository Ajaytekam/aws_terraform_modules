variable "usernames" {
  description = "List of IAM usernames to create"
  type        = list(string)
}

variable "tags" {
  description = "Tags to attach to IAM users"
  type        = map(string)
  default     = {}
}

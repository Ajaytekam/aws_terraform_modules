variable "app_name" { type = string }
variable "repository_url" { type = string }
variable "github_token" { type = string; sensitive = true }
variable "branch_name" { type = string; default = "main" }
variable "tags" { type = map(string); default = {} }

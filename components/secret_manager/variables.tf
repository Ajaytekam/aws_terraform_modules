variable "secret_name" { type = string }
variable "description" { type = string; default = "Managed by Terraform" }
variable "secret_value" { type = string; sensitive = true; default = null }
variable "recovery_window_in_days" { type = number; default = 0 }
variable "tags" { type = map(string); default = {} }

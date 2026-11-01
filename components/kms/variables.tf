variable "alias_name" { type = string; description = "Alias name (e.g. app-data-key)" }
variable "description" { type = string; default = "Customer managed KMS key" }
variable "deletion_window_in_days" { type = number; default = 30 }
variable "tags" { type = map(string); default = {} }

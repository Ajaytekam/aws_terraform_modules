variable "repository_name" { type = string }
variable "mutability" { type = string; default = "MUTABLE" }
variable "tags" { type = map(string); default = {} }

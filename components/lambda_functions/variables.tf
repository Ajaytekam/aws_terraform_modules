variable "function_name" { type = string }
variable "runtime" { type = string; default = "nodejs20.x" }
variable "handler" { type = string; default = "index.handler" }
variable "filename" { type = string }
variable "timeout" { type = number; default = 10 }
variable "memory_size" { type = number; default = 128 }
variable "environment_variables" { type = map(string); default = {} }
variable "tags" { type = map(string); default = {} }

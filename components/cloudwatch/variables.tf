variable "log_group_name" { type = string }
variable "retention_in_days" { type = number; default = 30 }
variable "create_cpu_alarm" { type = bool; default = false }
variable "tags" { type = map(string); default = {} }

variable "name" { type = string; description = "Name prefix for the ALB" }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "internal" { type = bool; default = false }
variable "target_port" { type = number; default = 80 }
variable "health_check_path" { type = string; default = "/" }
variable "allowed_cidr_blocks" { type = list(string); default = ["0.0.0.0/0"] }
variable "enable_deletion_protection" { type = bool; default = false }
variable "tags" { type = map(string); default = {} }

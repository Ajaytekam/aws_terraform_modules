variable "name" {
  description = "Prefix name for the VPC resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "Tags to attach to all VPC resources"
  type        = map(string)
  default     = {}
}

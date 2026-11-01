variable "name" {
  description = "Name for the Auto Scaling Group resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ASG instances will be launched"
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnet IDs for the ASG instances"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for launch template. If omitted, the latest Amazon Linux 2023 AMI is used."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 80
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB to allow ingress from"
  type        = string
}

variable "target_group_arns" {
  description = "Target group ARNs to register the ASG instances with"
  type        = list(string)
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}

variable "volume_size" {
  description = "EBS volume size in GB"
  type        = number
  default     = 20
}

variable "user_data" {
  description = "User data script to bootstrap instances"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to attach to resources"
  type        = map(string)
  default     = {}
}

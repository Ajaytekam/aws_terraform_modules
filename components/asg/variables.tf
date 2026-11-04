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

variable "architecture" {
  description = "CPU architecture for the dynamic AMI lookup: 'x86_64' (amd64) or 'arm64'."
  type        = string
  default     = "x86_64"
  validation {
    condition     = contains(["x86_64", "amd64", "arm64"], lower(var.architecture))
    error_message = "Architecture must be one of: 'x86_64', 'amd64', or 'arm64'."
  }
}

variable "instance_type" {
  description = "EC2 instance size. If omitted, defaults to t4g.micro for arm64 and t3.micro for x86_64/amd64."
  type        = string
  default     = null
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
  description = "User data script to bootstrap instances (can also be a path to a script file)"
  type        = string
  default     = null
}

variable "user_data_file" {
  description = "Path to a start script / user data file to bootstrap instances. Supports plain shell scripts or templated scripts."
  type        = string
  default     = null
}

variable "start_script_file" {
  description = "Alias for user_data_file. Path to a start script file to bootstrap instances."
  type        = string
  default     = null
}

variable "user_data_vars" {
  description = "Optional map of variables to render into the user data template file"
  type        = map(any)
  default     = {}
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

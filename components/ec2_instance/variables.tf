variable "name" {
  description = "Name for the EC2 instance and associated resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the security group is created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance. If omitted, the latest Amazon Linux 2023 AMI is dynamically fetched."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

variable "volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 20
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to associate with the instance"
  type        = string
  default     = null
}

variable "create_key_pair" {
  description = "Automatically generate a new SSH private/public key pair"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "Name of an existing AWS Key Pair or custom name for the new key"
  type        = string
  default     = null
}

variable "public_key" {
  description = "Existing public key material (e.g. file('~/.ssh/id_rsa.pub')) to import into AWS"
  type        = string
  default     = null
}

variable "enable_ssh" {
  description = "Allow inbound SSH traffic on port 22 in the security group. Defaults to true if a key is configured."
  type        = bool
  default     = null
}

variable "ssh_allowed_cidr_blocks" {
  description = "CIDR blocks allowed for inbound SSH traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = null
}

variable "tags" {
  description = "Tags to attach to the instance and security group"
  type        = map(string)
  default     = {}
}

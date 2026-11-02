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

variable "user_data" {
  description = "User data script / initialization script to execute on first boot"
  type        = string
  default     = null
}

variable "enable_ssm_public" {
  description = "Enable AWS Systems Manager (SSM) for instances in public subnets. Automatically provisions IAM instance profile with AmazonSSMManagedInstanceCore."
  type        = bool
  default     = false
}

variable "enable_ssm_private" {
  description = "Enable AWS Systems Manager (SSM) for instances in private subnets. Automatically provisions IAM instance profile and required VPC Interface Endpoints (ssm, ssmmessages, ec2messages) for private connectivity."
  type        = bool
  default     = false
}

variable "create_ssm_endpoints" {
  description = "Whether to create VPC Interface Endpoints when enable_ssm_private is true. Set to false if the VPC already has SSM endpoints."
  type        = bool
  default     = true
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the SSM VPC Endpoints. If omitted, uses [var.subnet_id]."
  type        = list(string)
  default     = []
}

variable "enable_public_ssh" {
  description = "If true, opens port 22 in both the Security Group and the subnet's Network ACL"
  type        = bool
  default     = false
}

variable "network_acl_id" {
  description = "Network ACL ID of the subnet. If omitted and enable_public_ssh is true, discovered automatically."
  type        = string
  default     = null
}

variable "nacl_ssh_rule_number" {
  description = "Rule number for the SSH ingress rule in the Network ACL"
  type        = number
  default     = 90
}

variable "enable_ssh" {
  description = "Legacy alias for enable_public_ssh. If true, opens port 22 in both Security Group and NACL."
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

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

# 1. Key Pair Configuration
# Automatically generate a 4096-bit RSA private key if create_key_pair = true and no public_key is passed
resource "tls_private_key" "this" {
  count     = var.create_key_pair && var.public_key == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Register AWS key pair from generated TLS key or user-supplied public_key
resource "aws_key_pair" "this" {
  count      = var.create_key_pair || var.public_key != null ? 1 : 0
  key_name   = coalesce(var.key_name, "${var.name}-key")
  public_key = var.public_key != null ? var.public_key : tls_private_key.this[0].public_key_openssh
  tags       = var.tags
}

locals {
  arch_normalized = lower(var.architecture) == "arm64" ? "arm64" : "x86_64"
}

# Dynamically fetch latest Amazon Linux 2023 AMI if var.ami_id is not provided
data "aws_ami" "amazon_linux_2023" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-${local.arch_normalized}"]
  }

  filter {
    name   = "architecture"
    values = [local.arch_normalized]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  instance_type = var.instance_type != null ? var.instance_type : (local.arch_normalized == "arm64" ? "t4g.micro" : "t3.micro")
  ami_id        = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux_2023[0].id
  key_name      = var.key_name != null && !var.create_key_pair && var.public_key == null ? var.key_name : try(aws_key_pair.this[0].key_name, null)
  enable_ssh    = var.enable_public_ssh || (var.enable_ssh == true)
}

# 2. Security Group with optional SSH ingress
resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.enable_ssh ? [1] : []
    content {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_allowed_cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# 3. Network ACL Rule for SSH (Only created when enable_public_ssh is true)
data "aws_network_acls" "subnet" {
  count  = local.enable_ssh && var.network_acl_id == null ? 1 : 0
  vpc_id = var.vpc_id
  filter {
    name   = "association.subnet-id"
    values = [var.subnet_id]
  }
}

locals {
  target_nacl_id = var.network_acl_id != null ? var.network_acl_id : try(tolist(data.aws_network_acls.subnet[0].ids)[0], null)
}

resource "aws_network_acl_rule" "ssh" {
  count          = local.enable_ssh && local.target_nacl_id != null ? 1 : 0
  network_acl_id = local.target_nacl_id
  rule_number    = var.nacl_ssh_rule_number
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.ssh_allowed_cidr_blocks[0]
  from_port      = 22
  to_port        = 22
}

# 4. EC2 Instance
resource "aws_instance" "this" {
  ami                         = local.ami_id
  instance_type               = local.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = local.key_name
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids      = [aws_security_group.this.id]
  iam_instance_profile        = var.iam_instance_profile
  user_data                   = var.user_data

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(var.tags, { Name = var.name })
}

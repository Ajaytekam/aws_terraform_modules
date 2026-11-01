# 1. ASG Security Group: Only permits traffic FROM the ALB Security Group
resource "aws_security_group" "asg" {
  name        = "${var.name}-asg-sg"
  description = "Security group for ${var.name} instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic only from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-asg-sg" })
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
}

# 2. Launch Template (Instance blueprint)
resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-lt-"
  image_id      = local.ami_id
  instance_type = local.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.asg.id]
  }

  user_data = var.user_data != null ? base64encode(var.user_data) : null

  # Encrypted root storage
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  # Security Best Practice: Enforce IMDSv2 to prevent SSRF credential theft
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.name}-asg-instance" })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 3. Auto Scaling Group
resource "aws_autoscaling_group" "this" {
  name_prefix         = "${var.name}-asg-"
  vpc_zone_identifier = var.private_subnet_ids

  # Target sizes
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  # Automatic registration with ALB Target Group
  target_group_arns = var.target_group_arns

  # Use ELB health check so unhealthy instances are replaced automatically
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity] # Allows AWS scaling policies to control capacity
  }
}

# 4. Target Tracking Scaling Policy (Maintains 70% average CPU)
resource "aws_autoscaling_policy" "cpu_tracking" {
  name                   = "${var.name}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

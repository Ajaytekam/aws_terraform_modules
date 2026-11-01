## AWS Terraform Modules

A modular collection of production-ready, reusable AWS Terraform modules located in the `components/` directory.

### Provider Configuration

Create a `provider.tf` file in your root directory:

```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

---

## Available Modules & Sample Usages

### 1. Networking & VPC
- **Module:** `components/vpc`
- **Description:** Deploys a VPC with public & private subnets across multiple AZs, Internet Gateway, NAT Gateway, NACLs, and baseline Security Groups.

```hcl
module "vpc" {
  source   = "./components/vpc"
  name     = "app-network"
  vpc_cidr = "10.0.0.0/16"

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

---

### 2. Storage & Security

#### S3 Bucket
- **Module:** `components/s3_buckets`
- **Description:** Encrypted, versioned S3 bucket with all public access blocked by default.

```hcl
module "s3_bucket" {
  source        = "./components/s3_buckets"
  bucket_name   = "my-unique-app-data-bucket-2026"
  versioning    = true
  force_destroy = false

  tags = {
    Environment = "dev"
  }
}
```

#### AWS KMS Key
- **Module:** `components/kms`
- **Description:** Customer managed KMS key with automatic rotation and key alias.

```hcl
module "kms" {
  source                  = "./components/kms"
  alias_name              = "app-data-key"
  description             = "Customer managed KMS key for data encryption"
  deletion_window_in_days = 30

  tags = {
    Environment = "dev"
  }
}
```

#### AWS Secrets Manager
- **Module:** `components/secret_manager`
- **Description:** Securely store database credentials or API tokens.

```hcl
module "db_secret" {
  source                  = "./components/secret_manager"
  secret_name             = "app/database/credentials"
  description             = "Database admin credentials"
  secret_value            = "StrongPassword123!"
  recovery_window_in_days = 0

  tags = {
    Environment = "dev"
  }
}
```

---

### 3. Compute & Auto-Scaling

#### EC2 Instance
- **Module:** `components/ec2_instance`
- **Description:** Single EC2 instance with encrypted EBS root volume, optional auto-generated or custom SSH key pair, configurable SSH security group ingress rule, and public/private IP outputs.

**Option A: Auto-generate a private key pair for SSH**
```hcl
module "ec2" {
  source                  = "./components/ec2_instance"
  name                    = "app-server"
  vpc_id                  = module.vpc.vpc_id
  subnet_id               = module.vpc.public_subnet_ids[0]
  # ami_id                = "ami-xxxxxx"            # Optional: defaults to latest Amazon Linux 2023
  instance_type           = "t3.micro"
  volume_size             = 20
  create_key_pair         = true                    # Generates a new 4096-bit RSA key pair
  enable_ssh              = true                    # Opens port 22 in security group
  ssh_allowed_cidr_blocks = ["0.0.0.0/0"]           # Or restrict to your IP: ["x.x.x.x/32"]

  tags = {
    Environment = "dev"
  }
}

# Output the private key and public IP to connect
output "ec2_private_key" {
  value     = module.ec2.private_key_pem
  sensitive = true
}

output "ec2_public_ip" {
  value = module.ec2.public_ip
}
```

> **How to SSH into your instance using the generated key:**
> ```bash
> # 1. Extract and save the private key
> terraform output -raw ec2_private_key > ec2-key.pem
> chmod 400 ec2-key.pem
>
> # 2. Connect via SSH
> ssh -i ec2-key.pem ec2-user@<ec2_public_ip>
> ```

**Option B: Use an existing AWS Key Pair or local public key**
```hcl
module "ec2" {
  source    = "./components/ec2_instance"
  name      = "app-server"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]
  ami_id    = "ami-0c55b159cbfafe1f0"

  # Choice 1: Existing key name already in AWS
  key_name  = "my-existing-aws-key"

  # Choice 2: Or import from local public key file
  # public_key = file("~/.ssh/id_rsa.pub")

  tags = {
    Environment = "dev"
  }
}
```

#### Application Load Balancer (ALB)
- **Module:** `components/alb`
- **Description:** Public/internal ALB, HTTP/HTTPS listener, target group, and ingress security group.

```hcl
module "alb" {
  source              = "./components/alb"
  name                = "web-alb"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  internal            = false
  target_port         = 80
  health_check_path   = "/"
  allowed_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Environment = "dev"
  }
}
```

#### Auto Scaling Group (ASG)
- **Module:** `components/asg`
- **Description:** Launch Template and ASG connected to ALB target groups, restricted to ALB ingress.

```hcl
module "asg" {
  source                = "./components/asg"
  name                  = "web-asg"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  # ami_id              = "ami-xxxxxx" # Optional: defaults to latest Amazon Linux 2023
  instance_type         = "t3.micro"
  app_port              = 80
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arns     = [module.alb.target_group_arn]
  min_size              = 1
  max_size              = 4
  desired_capacity      = 2
  volume_size           = 20

  tags = {
    Environment = "dev"
  }
}
```

---

### 4. Database

#### Relational Database Service (RDS)
- **Module:** `components/rds`
- **Description:** RDS instance (Postgres/MySQL) with DB subnet group, security group, and gp3 encrypted storage.

```hcl
module "rds" {
  source              = "./components/rds"
  db_name             = "app-db-instance"
  database_name       = "appdb"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  engine              = "postgres"
  engine_version      = "15.4"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  port                = 5432
  username            = "dbadmin"
  password            = "ReplaceWithSecurePassword123!"
  allowed_cidr_blocks = ["10.0.0.0/16"]
  skip_final_snapshot = true

  tags = {
    Environment = "dev"
  }
}
```

---

### 5. Containers & Serverless

#### AWS Lambda Function
- **Module:** `components/lambda_functions`
- **Description:** Lambda function with IAM execution role and CloudWatch logging permissions.

```hcl
module "lambda" {
  source        = "./components/lambda_functions"
  function_name = "order-processor"
  runtime       = "nodejs20.x"
  handler       = "index.handler"
  filename      = "lambda.zip"
  timeout       = 10
  memory_size   = 128
  environment_variables = {
    STAGE = "dev"
  }

  tags = {
    Environment = "dev"
  }
}
```

#### Amazon ECR (Elastic Container Registry)
- **Module:** `components/ecr`
- **Description:** Private container registry with image scanning on push.

```hcl
module "ecr" {
  source          = "./components/ecr"
  repository_name = "backend-service"
  mutability      = "MUTABLE"

  tags = {
    Environment = "dev"
  }
}
```

#### Amazon EKS (Elastic Kubernetes Service)
- **Module:** `components/eks`
- **Description:** Managed Kubernetes cluster with IAM roles and managed worker node group.

```hcl
module "eks" {
  source             = "./components/eks"
  cluster_name       = "main-eks-cluster"
  kubernetes_version = "1.29"
  subnet_ids         = module.vpc.private_subnet_ids
  instance_types     = ["t3.medium"]
  desired_size       = 2
  min_size           = 1
  max_size           = 4
}
```

---

### 6. Edge & Web Services

#### Amazon API Gateway (HTTP API)
- **Module:** `components/api_gateway`
- **Description:** Serverless HTTP API v2 with automatic deployment stage.

```hcl
module "api_gateway" {
  source   = "./components/api_gateway"
  api_name = "customer-http-api"

  tags = {
    Environment = "dev"
  }
}
```

#### Amazon CloudFront Distribution
- **Module:** `components/cloudfront`
- **Description:** CDN distribution for S3 bucket or custom origin with HTTPS redirect.

```hcl
module "cloudfront" {
  source             = "./components/cloudfront"
  origin_domain_name = "my-bucket.s3.amazonaws.com"
  origin_id          = "s3-static-origin"

  tags = {
    Environment = "dev"
  }
}
```

#### Amazon Route 53 DNS Record
- **Module:** `components/route53`
- **Description:** Route 53 DNS resource record.

```hcl
module "route53_record" {
  source      = "./components/route53"
  zone_id     = "Z0123456789ABCDEF"
  record_name = "api.example.com"
  record_type = "CNAME"
  ttl         = 300
  records     = [module.alb.alb_dns_name]
}
```

#### AWS Amplify
- **Module:** `components/amplify`
- **Description:** Fully managed web app hosting connected to a GitHub repository branch.

```hcl
module "amplify_app" {
  source         = "./components/amplify"
  app_name       = "my-frontend-portal"
  repository_url = "https://github.com/my-org/portal-ui"
  github_token   = "ghp_PersonalAccessToken"
  branch_name    = "main"

  tags = {
    Environment = "dev"
  }
}
```

---

### 7. Messaging & Event-Driven Architecture

#### Amazon SQS (Simple Queue Service)
- **Module:** `components/sqs`
- **Description:** Standard SQS queue with an integrated Dead-Letter Queue (DLQ) and SSE encryption.

```hcl
module "sqs" {
  source                     = "./components/sqs"
  name                       = "task-processing-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600 # 4 days
  receive_wait_time_seconds  = 20     # Long polling
  enable_dlq                 = true
  max_receive_count          = 5

  tags = {
    Environment = "dev"
  }
}
```

#### Amazon SNS (Simple Notification Service)
- **Module:** `components/sns`
- **Description:** Encrypted SNS topic with optional email, Lambda, or SQS subscriptions.

```hcl
module "sns" {
  source = "./components/sns"
  name   = "critical-alerts-topic"
  subscriptions = {
    devops_email = {
      protocol = "email"
      endpoint = "devops-alerts@example.com"
    }
  }

  tags = {
    Environment = "dev"
  }
}
```

#### Amazon EventBridge
- **Module:** `components/eventbridge`
- **Description:** Event bus, event rule (cron or pattern), and event target (SQS, SNS, Lambda).

```hcl
module "eventbridge" {
  source              = "./components/eventbridge"
  create_custom_bus   = true
  bus_name            = "app-event-bus"
  rule_name           = "daily-midnight-trigger"
  rule_description    = "Fires daily at 00:00 UTC"
  schedule_expression = "cron(0 0 * * ? *)"
  target_arn          = module.sqs.queue_arn

  tags = {
    Environment = "dev"
  }
}
```

---

### 8. Identity & Access Management (IAM)

#### IAM Users
- **Module:** `components/iam_user`
- **Description:** Creates IAM users with `force_destroy` enabled.

```hcl
module "iam_users" {
  source    = "./components/iam_user"
  usernames = ["developer.one", "developer.two"]

  tags = {
    Environment = "dev"
  }
}
```

#### IAM Custom Policy
- **Module:** `components/iam_policy`
- **Description:** Declarative IAM policy generator with actions, resources, and condition support.

```hcl
module "s3_read_policy" {
  source             = "./components/iam_policy"
  policy_name        = "S3ReadOnlyAppPolicy"
  policy_description = "Grants read access to S3"
  statements = [
    {
      sid       = "AllowS3Read"
      effect    = "Allow"
      actions   = ["s3:GetObject", "s3:ListBucket"]
      resources = ["*"]
    }
  ]

  tags = {
    Environment = "dev"
  }
}
```

#### IAM Group
- **Module:** `components/iam_group`
- **Description:** IAM group with user memberships and attached policy ARNs.

```hcl
module "iam_group" {
  source      = "./components/iam_group"
  group_name  = "engineering-team"
  members     = module.iam_users.user_names
  policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    module.s3_read_policy.policy_arn
  ]
}
```

---

### 9. Monitoring & Observability

#### Amazon CloudWatch
- **Module:** `components/cloudwatch`
- **Description:** CloudWatch Log Group with configurable retention and optional CPU metric alarms.

```hcl
module "cloudwatch" {
  source            = "./components/cloudwatch"
  log_group_name    = "/aws/app/backend-service"
  retention_in_days = 30
  create_cpu_alarm  = true

  tags = {
    Environment = "dev"
  }
}
```

---

### Complete End-to-End Architecture Example

Below is a combined example showing how to compose multiple modules together (VPC + S3 + RDS + ALB + ASG):

```hcl
# 1. Base VPC
module "vpc" {
  source   = "./components/vpc"
  name     = "production"
  vpc_cidr = "10.0.0.0/16"
}

# 2. S3 Bucket for App Assets
module "app_storage" {
  source      = "./components/s3_buckets"
  bucket_name = "my-company-prod-assets-2026"
  versioning  = true
}

# 3. Application Load Balancer
module "alb" {
  source            = "./components/alb"
  name              = "prod-web-alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  target_port       = 80
}

# 4. Auto Scaling Group linked to ALB
module "asg" {
  source                = "./components/asg"
  name                  = "prod-web-asg"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  # ami_id automatically defaults to the latest Amazon Linux 2023
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arns     = [module.alb.target_group_arn]
  desired_capacity      = 2
}

# 5. RDS Database in Private Subnets
module "database" {
  source         = "./components/rds"
  db_name        = "prod-db-instance"
  database_name  = "proddb"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  instance_class = "db.t3.micro"
  password       = "ReplaceWithSecurePassword123!"
}
```

---

### Standard Terraform Workflow

```bash
# Initialize and download provider plugins
terraform init

# Validate configuration syntax
terraform validate

# Preview changes before applying
terraform plan

# Apply infrastructure changes
terraform apply

# Destroy resources when done
terraform destroy
```

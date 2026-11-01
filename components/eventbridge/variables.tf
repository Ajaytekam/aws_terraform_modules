variable "create_custom_bus" { type = bool; default = false }
variable "bus_name" { type = string; default = "app-event-bus" }
variable "rule_name" { type = string }
variable "rule_description" { type = string; default = "Managed by Terraform" }
variable "event_pattern" { type = string; default = null } # JSON string
variable "schedule_expression" { type = string; default = null } # e.g. "cron(0 12 * * ? *)"
variable "target_arn" { type = string; description = "ARN of SQS, SNS, Lambda, or Step Function target" }
variable "tags" { type = map(string); default = {} }

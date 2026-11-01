# 1. Custom Event Bus (Optional: uses default bus if null)
resource "aws_cloudwatch_event_bus" "this" {
  count = var.create_custom_bus ? 1 : 0
  name  = var.bus_name
  tags  = var.tags
}

locals {
  bus_name = var.create_custom_bus ? aws_cloudwatch_event_bus.this[0].name : "default"
}

# 2. Event Rule (Filter events based on pattern or cron schedule)
resource "aws_cloudwatch_event_rule" "this" {
  name                = var.rule_name
  description         = var.rule_description
  event_bus_name      = local.bus_name
  event_pattern       = var.event_pattern
  schedule_expression = var.schedule_expression
  tags                = var.tags
}

# 3. Event Target (Sends matched events to SQS, SNS, Lambda, Step Functions, etc.)
resource "aws_cloudwatch_event_target" "this" {
  rule           = aws_cloudwatch_event_rule.this.name
  event_bus_name = local.bus_name
  target_id      = "${var.rule_name}-target"
  arn            = var.target_arn
}

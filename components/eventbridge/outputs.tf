output "bus_name" { value = local.bus_name }
output "rule_arn" { value = aws_cloudwatch_event_rule.this.arn }

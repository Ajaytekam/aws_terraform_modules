resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
  tags              = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  count               = var.create_cpu_alarm ? 1 : 0
  alarm_name          = "${var.log_group_name}-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when server CPU exceeds 80%"
  tags                = var.tags
}

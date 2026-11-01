resource "aws_sns_topic" "this" {
  name              = var.name
  kms_master_key_id = var.kms_key_id # Uses KMS or default AWS-managed encryption
  tags              = var.tags
}

# Optional subscriptions (e.g. Email alerts, Lambda, SQS)
resource "aws_sns_topic_subscription" "this" {
  for_each  = var.subscriptions
  topic_arn = aws_sns_topic.this.arn
  protocol  = each.value.protocol # email, sqs, lambda, https
  endpoint  = each.value.endpoint
}

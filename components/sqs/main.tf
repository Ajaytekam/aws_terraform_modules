# 1. Dead-Letter Queue (DLQ)
resource "aws_sqs_queue" "dlq" {
  count                     = var.enable_dlq ? 1 : 0
  name                      = "${var.name}-dlq"
  sqs_managed_sse_enabled   = true
  message_retention_seconds = 1209600 # 14 days retention for troubleshooting
  tags                      = var.tags
}

# 2. Main SQS Queue
resource "aws_sqs_queue" "this" {
  name                       = var.name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  delay_seconds              = var.delay_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds # Long polling
  sqs_managed_sse_enabled    = var.kms_master_key_id == null ? true : null
  kms_master_key_id          = var.kms_master_key_id

  # Automatically wire DLQ if enabled
  redrive_policy = var.enable_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  tags = var.tags
}

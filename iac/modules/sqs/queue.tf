resource "aws_sqs_queue" "dlq" {
  name                      = var.dead_letter_queue_name
  message_retention_seconds = 1209600

  tags = merge(local.common_tags, {
    Name = var.dead_letter_queue_name
  })
}

resource "aws_sqs_queue" "this" {
  name                       = var.queue_name
  visibility_timeout_seconds = 360
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })

  tags = local.common_tags
}

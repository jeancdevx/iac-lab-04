resource "aws_cloudwatch_metric_alarm" "dlq_visible_messages" {
  alarm_name          = "${var.name_prefix}-dlq-visible-messages"
  alarm_description   = "Triggers when the DLQ has visible messages"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  dimensions = {
    QueueName = var.dead_letter_queue_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = toset(var.lambda_function_names)

  alarm_name          = "${var.name_prefix}-${each.value}-errors"
  alarm_description   = "Triggers when Lambda errors are detected"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  dimensions = {
    FunctionName = each.value
  }

  tags = var.tags
}

output "dlq_alarm_name" {
  value = aws_cloudwatch_metric_alarm.dlq_visible_messages.alarm_name
}

output "lambda_error_alarm_names" {
  value = [for alarm in aws_cloudwatch_metric_alarm.lambda_errors : alarm.alarm_name]
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "notification_queue_arn" {
  description = "ARN of the SQS queue that receives upload notifications"
  type        = string
}

variable "tags" {
  description = "Tags applied to S3 resources"
  type        = map(string)
  default     = {}
}

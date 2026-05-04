variable "queue_name" {
  description = "Name of the main SQS queue"
  type        = string
}

variable "dead_letter_queue_name" {
  description = "Name of the dead-letter queue"
  type        = string
}

variable "source_bucket_arn" {
  description = "ARN of the S3 bucket allowed to send messages"
  type        = string
}

variable "tags" {
  description = "Tags applied to SQS resources"
  type        = map(string)
  default     = {}
}

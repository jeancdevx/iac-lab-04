variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "source_dir" {
  description = "Path to the Lambda function source code directory"
  type        = string
}

variable "s3_bucket" {
  description = "Name of the S3 bucket where images are stored"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue that receives S3 notifications"
  type        = string
}

variable "vpc_config" {
  description = "VPC configuration for the Lambda"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "aws_profile" {
  description = "Optional AWS CLI profile to use for local image build/push"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to Lambda resources"
  type        = map(string)
  default     = {}
}

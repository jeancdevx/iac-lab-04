variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "source_dir" {
  description = "Path to the Lambda function source code directory"
  type        = string
}

variable "s3_bucket" {
  description = "Name of the S3 bucket where images will be uploaded"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
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

variable "tags" {
  description = "Tags applied to Lambda resources"
  type        = map(string)
  default     = {}
}

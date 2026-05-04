variable "name_prefix" {
  description = "Prefix used for alarm names"
  type        = string
}

variable "dead_letter_queue_name" {
  description = "Name of the DLQ to monitor"
  type        = string
}

variable "lambda_function_names" {
  description = "Lambda function names to monitor for errors"
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to observability resources"
  type        = map(string)
  default     = {}
}

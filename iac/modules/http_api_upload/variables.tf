variable "api_name" {
  description = "Name of the HTTP API"
  type        = string
}

variable "route_path" {
  description = "HTTP route path"
  type        = string
  default     = "/upload"
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function invoked by the API"
  type        = string
}

variable "tags" {
  description = "Tags applied to API resources"
  type        = map(string)
  default     = {}
}

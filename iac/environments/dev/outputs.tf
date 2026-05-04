output "vpc_id" {
  description = "ID of the shared VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "s3_vpc_endpoint_id" {
  description = "S3 gateway VPC endpoint id"
  value       = module.vpc.s3_vpc_endpoint_id
}

output "sqs_vpc_endpoint_id" {
  description = "SQS interface VPC endpoint id"
  value       = module.vpc.sqs_vpc_endpoint_id
}

output "nat_gateway_ids" {
  description = "IDs of created NAT gateways (if any)"
  value       = module.vpc.nat_gateway_ids
}

output "bucket_name" {
  description = "Name of the images bucket"
  value       = module.s3.bucket_name
}

output "bucket_arn" {
  description = "ARN of the images bucket"
  value       = module.s3.bucket_arn
}

output "queue_name" {
  description = "Name of the main SQS queue"
  value       = module.sqs.queue_name
}

output "queue_arn" {
  description = "ARN of the main SQS queue"
  value       = module.sqs.queue_arn
}

output "dlq_arn" {
  description = "ARN of the dead-letter queue"
  value       = module.sqs.dlq_arn
}

output "upload_lambda_function_arn" {
  description = "ARN of the upload Lambda function"
  value       = module.lambda_upload.function_arn
}

output "upload_lambda_function_name" {
  description = "Name of the upload Lambda function"
  value       = module.lambda_upload.function_name
}

output "upload_api_endpoint" {
  description = "Base URL of the HTTP API for image uploads"
  value       = module.http_api_upload.api_endpoint
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "lambda_upload_security_group_id" {
  description = "Security group for the upload Lambda"
  value       = aws_security_group.lambda_upload.id
}

output "lambda_crop_security_group_id" {
  description = "Security group for the crop Lambda"
  value       = aws_security_group.lambda_crop.id
}

output "sqs_endpoint_security_group_id" {
  description = "Security group attached to the SQS VPC endpoint"
  value       = aws_security_group.sqs_endpoint.id
}

output "s3_vpc_endpoint_id" {
  description = "Gateway endpoint for S3"
  value       = aws_vpc_endpoint.s3.id
}

output "sqs_vpc_endpoint_id" {
  description = "Interface endpoint for SQS"
  value       = aws_vpc_endpoint.sqs.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT gateways"
  value       = [for nat_gateway in aws_nat_gateway.this : nat_gateway.id]
}

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

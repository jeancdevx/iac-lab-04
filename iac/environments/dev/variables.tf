variable "aws_region" {
  description = "AWS region where development resources are provisioned"
  type        = string
  default     = "us-east-2"
}

variable "aws_profile" {
  description = "AWS shared config profile name (useful for AWS SSO)"
  type        = string
  default     = null
}

variable "project_name" {
  description = "Project identifier used in naming and tagging"
  type        = string
  default     = "lab-04"
}

variable "environment" {
  description = "Environment identifier"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones used by the architecture"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "The architecture expects exactly two availability zones."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "The architecture expects exactly two public subnets."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "The architecture expects exactly two private subnets."
  }
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT gateways for private subnet egress"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to reuse one NAT gateway for both AZs"
  type        = bool
  default     = false
}

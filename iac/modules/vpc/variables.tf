variable "name_prefix" {
  description = "Prefix used for resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS region used to build regional service names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones used by the VPC"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "The VPC module expects exactly two availability zones."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "The VPC module expects exactly two public subnets."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "The VPC module expects exactly two private subnets."
  }
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT gateways"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to reuse a single NAT gateway for both private subnets"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to all VPC resources"
  type        = map(string)
  default     = {}
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

module "vpc" {
  source = "../../modules/vpc"

  name_prefix          = local.name_prefix
  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  tags                 = local.default_tags
}

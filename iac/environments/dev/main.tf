locals {
  name_prefix = "${var.project_name}-${var.environment}"
  bucket_name = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}-images"
  queue_name  = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}-image-queue"
  dlq_name    = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}-image-dlq"
}

data "aws_caller_identity" "current" {}

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

module "sqs" {
  source = "../../modules/sqs"

  queue_name             = local.queue_name
  dead_letter_queue_name = local.dlq_name
  source_bucket_arn      = "arn:aws:s3:::${local.bucket_name}"
  tags                   = local.default_tags
}

module "s3" {
  source = "../../modules/s3"

  bucket_name            = local.bucket_name
  notification_queue_arn = module.sqs.queue_arn
  tags                   = local.default_tags

  depends_on = [module.sqs]
}

module "lambda_upload" {
  source = "../../modules/lambda_upload"

  function_name = "${local.name_prefix}-upload-lambda"
  source_dir    = abspath("${path.module}/../../../services/upload-lambda")
  s3_bucket     = module.s3.bucket_name
  s3_bucket_arn = module.s3.bucket_arn

  aws_profile = var.aws_profile

  vpc_config = {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [module.vpc.lambda_upload_security_group_id]
  }

  tags = local.default_tags

  depends_on = [module.s3]
}

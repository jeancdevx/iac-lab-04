data "aws_region" "current" {}

resource "aws_ecr_repository" "this" {
  name                 = var.function_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
}

resource "null_resource" "image_build_push" {
  triggers = {
    image_tag = local.image_tag
  }

  provisioner "local-exec" {
    command     = <<-EOT
      set -euo pipefail
      aws ecr get-login-password --region ${data.aws_region.current.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.this.repository_url}
      docker build -t ${aws_ecr_repository.this.repository_url}:${local.image_tag} ${var.source_dir}
      docker push ${aws_ecr_repository.this.repository_url}:${local.image_tag}
    EOT
    interpreter = ["/bin/sh", "-c"]
    environment = {
      AWS_PROFILE = var.aws_profile
    }
  }

  depends_on = [aws_ecr_repository.this]
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.this.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.this.repository_url}:${local.image_tag}"
  timeout       = 30
  memory_size   = 256

  environment {
    variables = {
      S3_BUCKET     = var.s3_bucket
      UPLOAD_PREFIX = "uploads"
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []

    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tags = local.common_tags

  depends_on = [
    null_resource.image_build_push,
    aws_iam_role_policy.s3_put_uploads,
    aws_iam_role_policy_attachment.lambda_basic_execution,
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14

  tags = local.common_tags
}

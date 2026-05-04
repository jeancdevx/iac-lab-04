data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  count      = var.vpc_config != null ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "s3_put_uploads" {
  statement {
    sid    = "PutObjectToUploadsPrefix"
    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = ["${var.s3_bucket_arn}/uploads/*"]
  }
}

resource "aws_iam_role_policy" "s3_put_uploads" {
  name   = "${var.function_name}-s3-put-uploads"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.s3_put_uploads.json
}

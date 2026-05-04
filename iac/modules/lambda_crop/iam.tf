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

data "aws_iam_policy_document" "s3_get_put" {
  statement {
    sid    = "GetObjectFromUploads"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${var.s3_bucket_arn}/uploads/*",
      "${var.s3_bucket_arn}",
    ]
  }

  statement {
    sid    = "PutObjectToProcessed"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = ["${var.s3_bucket_arn}/processed/*"]
  }
}

resource "aws_iam_role_policy" "s3_get_put" {
  name   = "${var.function_name}-s3-get-put"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.s3_get_put.json
}

data "aws_iam_policy_document" "sqs_polling" {
  statement {
    sid    = "AllowSqsPolling"
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility",
    ]

    resources = [var.sqs_queue_arn]
  }
}

resource "aws_iam_role_policy" "sqs_polling" {
  name   = "${var.function_name}-sqs-polling"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.sqs_polling.json
}

data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${var.aws_region}.s3"
}

resource "aws_security_group" "lambda_upload" {
  name        = "${var.name_prefix}-upload-lambda-sg"
  description = "Security group for the upload Lambda"
  vpc_id      = aws_vpc.this.id

  egress {
    description     = "HTTPS to the S3 gateway endpoint"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [data.aws_prefix_list.s3.id]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-upload-lambda-sg"
  })
}

resource "aws_security_group" "lambda_crop" {
  name        = "${var.name_prefix}-crop-lambda-sg"
  description = "Security group for the crop Lambda"
  vpc_id      = aws_vpc.this.id

  egress {
    description = "HTTPS to the SQS interface endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description     = "HTTPS to the S3 gateway endpoint"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [data.aws_prefix_list.s3.id]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-crop-lambda-sg"
  })
}

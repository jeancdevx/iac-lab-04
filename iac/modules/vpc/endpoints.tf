resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [aws_route_table.public.id],
    [for route_table in aws_route_table.private : route_table.id]
  )

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-s3-endpoint"
  })
}

resource "aws_security_group" "sqs_endpoint" {
  name        = "${var.name_prefix}-sqs-endpoint-sg"
  description = "Security group for SQS interface endpoint"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "HTTPS from Lambda security groups"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_upload.id, aws_security_group.lambda_crop.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-sqs-endpoint-sg"
  })
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids  = [aws_security_group.sqs_endpoint.id]
  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-sqs-endpoint"
  })
}

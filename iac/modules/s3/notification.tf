resource "aws_s3_bucket_notification" "this" {
  bucket = aws_s3_bucket.this.id

  queue {
    queue_arn     = var.notification_queue_arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "uploads/"
  }

  depends_on = [aws_s3_bucket_public_access_block.this]
}

locals {
  common_tags = merge(var.tags, {
    Name = var.queue_name
  })
}

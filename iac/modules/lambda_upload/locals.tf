locals {
  common_tags = merge(var.tags, {
    Name = var.function_name
  })

  image_tag = substr(
    sha256(join("|", [
      filesha256("${var.source_dir}/Dockerfile"),
      filesha256("${var.source_dir}/.dockerignore"),
      filesha256("${var.source_dir}/index.js"),
      filesha256("${var.source_dir}/package.json"),
    ])),
    0,
    12,
  )
}

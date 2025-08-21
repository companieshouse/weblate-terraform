resource "aws_s3_bucket" "weblate_media" {
  bucket = "${var.environment}-weblate-media"
  tags   = { Name = "${local.weblate_tag}" }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.weblate_media.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

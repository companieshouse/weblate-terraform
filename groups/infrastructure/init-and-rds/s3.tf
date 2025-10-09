resource "aws_s3_bucket" "weblate_media" {
  bucket = "${var.config.s3_bucket_name}"
  tags   = { Name = "${var.config.weblate_tag}" }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.weblate_media.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "weblate_s3_policy" {
  name        = "WeblateS3Policy"
  description = "Allow Weblate ECS tasks to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.weblate_media.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = aws_s3_bucket.weblate_media.arn
      }
    ]
  })
}

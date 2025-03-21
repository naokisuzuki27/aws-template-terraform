# S3バケット（静的コンテンツ用）
resource "aws_s3_bucket" "frontend_assets" {
  bucket = "${local.name_prefix}-frontend-assets"
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-frontend-assets"
  })
}

# S3バケットのパブリックアクセス設定（CloudFrontからのみアクセス可能）
resource "aws_s3_bucket_public_access_block" "frontend_assets" {
  bucket = aws_s3_bucket.frontend_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3バケットポリシー（CloudFrontからのアクセスのみ許可）
resource "aws_s3_bucket_policy" "frontend_assets" {
  bucket = aws_s3_bucket.frontend_assets.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.frontend_assets.arn}/*"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.ecs_distribution.arn
          }
        }
      }
    ]
  })
}
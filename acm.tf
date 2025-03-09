provider "aws" {
  alias  = "virginia"
  region = "us-east-1"  # バージニア北部リージョン
}

resource "aws_acm_certificate" "cloudfront_cert" {
  provider = aws.virginia
  domain_name       = aws_cloudfront_distribution.ecs_distribution.domain_name
  validation_method = "DNS"
}
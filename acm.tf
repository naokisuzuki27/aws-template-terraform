# acm.tf
resource "aws_acm_certificate" "cloudfront_cert" {
  domain_name       = "*.cloudfront.net"  # 実際のCloudFrontドメインで証明書は不要（AWSが自動提供）
  validation_method = "DNS"
  
  # CloudFrontで利用する証明書はus-east-1リージョンに作成する必要がある
  provider = aws.us-east-1  # プロバイダーの設定が必要
  
  lifecycle {
    create_before_destroy = true
  }
  
  # 注意: 実際には不要。CloudFrontのデフォルトドメインは
  # AWSが自動的に証明書を提供するため
}
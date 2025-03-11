resource "aws_cloudfront_cache_policy" "minimal_cache_policy" {
  name        = "MinimalCache-TestPolicy"
  comment     = "Policy with minimal caching for testing"
  default_ttl = 60        # 1分間キャッシュ
  min_ttl     = 0
  max_ttl     = 300       # 最大5分まで
  
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"  # Cookieを無視
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Host", "Origin"]  # 必要最小限のヘッダーのみ
      }
    }
    query_strings_config {
      query_string_behavior = "all"
    }
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true
  }
}

# CloudFront ディストリビューション
# デフォルト証明書を使用するように変更
resource "aws_cloudfront_distribution" "ecs_distribution" {
  enabled             = true
  is_ipv6_enabled     = false
  comment             = "Test CloudFront distribution for existing ECS application"
  price_class         = "PriceClass_200"  # JAPAN
  
  # ALBをオリジンとして設定
  origin {
    domain_name = aws_lb.alb.dns_name
    origin_id   = "${local.name_prefix}-cloudfront"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"  # テスト用、ALBが HTTP のみの場合
      origin_ssl_protocols   = ["TLSv1.2"]
    }
    
    # 必要に応じてカスタムヘッダーを追加
    custom_header {
      name  = "X-Forwarded-Host"
      value = aws_lb.alb.dns_name
    }
  }
  
  # デフォルトのキャッシュ動作設定
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.name_prefix}-cloudfront"
    
    # 新しいキャッシュポリシーを使用
    cache_policy_id = aws_cloudfront_cache_policy.minimal_cache_policy.id
    
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }
  
  # 地域制限の設定
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  # デフォルト証明書を使用する設定
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
  # タグ
  tags = merge(local.common_tags, {
    Environment = "test"
    Name        = "test-ecs-cloudfront-distribution"
  })
  
  # 依存関係の削除（カスタム証明書を使用しないため）
  # depends_on = [aws_acm_certificate.cloudfront_cert]
  
  # ライフサイクル設定も必要なければ削除
  # lifecycle {
  #   ignore_changes = []
  # }
}
#####################################################################
# cloudfront_cache_policy
#####################################################################
resource "aws_cloudfront_cache_policy" "static_cache_policy" {
  name        = "StaticAssets-CachePolicy"
  comment     = "Policy for static assets with longer caching"
  default_ttl = 86400    # 1日
  min_ttl     = 3600     # 1時間
  max_ttl     = 31536000 # 1年
  
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true
  }
}

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

#####################################################################
# cloudfront_origin_access_control
#####################################################################
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "${local.name_prefix}-s3-oac"
  description                       = "OAC for S3 static assets"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#####################################################################
# cloudfront_distribution
#####################################################################
resource "aws_cloudfront_distribution" "ecs_distribution" {
  enabled             = true
  is_ipv6_enabled     = false
  comment             = "CloudFront distribution for Next.js application with SSR and static assets"
  price_class         = "PriceClass_200"  # JAPAN
  
  # ALBオリジン (SSR用)
  origin {
    domain_name = aws_lb.alb.dns_name
    origin_id   = "${local.name_prefix}-alb-origin"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
    
    custom_header {
      name  = "X-Forwarded-Host"
      value = aws_lb.alb.dns_name
    }
  }
  
  # S3オリジン (静的アセット用)
  origin {
    domain_name              = aws_s3_bucket.frontend_assets.bucket_regional_domain_name
    origin_id                = "${local.name_prefix}-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }
  
  # デフォルトのキャッシュ動作 (SSR向け)
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.name_prefix}-alb-origin"
    
    cache_policy_id = aws_cloudfront_cache_policy.minimal_cache_policy.id
    
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }
  
  # 静的アセット用のキャッシュ動作
  ordered_cache_behavior {
    path_pattern     = "/_next/static/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${local.name_prefix}-s3-origin"
    
    cache_policy_id = aws_cloudfront_cache_policy.static_cache_policy.id
    
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }
  
  # 画像用のキャッシュ動作
  ordered_cache_behavior {
    path_pattern     = "/images/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${local.name_prefix}-s3-origin"
    
    cache_policy_id = aws_cloudfront_cache_policy.static_cache_policy.id
    
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
    Environment = "production"
    Name        = "${local.name_prefix}-cloudfront-distribution"
  })
}

# # CloudFront キャッシュポリシー（静的アセット用）
# resource "aws_cloudfront_cache_policy" "static_cache_policy" {
#   name        = "StaticAssets-CachePolicy"
#   comment     = "Policy for static assets with longer caching"
#   default_ttl = 86400    # 1日
#   min_ttl     = 3600     # 1時間
#   max_ttl     = 31536000 # 1年
  
#   parameters_in_cache_key_and_forwarded_to_origin {
#     cookies_config {
#       cookie_behavior = "none"
#     }
#     headers_config {
#       header_behavior = "none"
#     }
#     query_strings_config {
#       query_string_behavior = "none"
#     }
#     enable_accept_encoding_gzip   = true
#     enable_accept_encoding_brotli = true
#   }
# }

# resource "aws_cloudfront_cache_policy" "minimal_cache_policy" {
#   name        = "MinimalCache-TestPolicy"
#   comment     = "Policy with minimal caching for testing"
#   default_ttl = 60        # 1分間キャッシュ
#   min_ttl     = 0
#   max_ttl     = 300       # 最大5分まで
  
#   parameters_in_cache_key_and_forwarded_to_origin {
#     cookies_config {
#       cookie_behavior = "none"  # Cookieを無視
#     }
#     headers_config {
#       header_behavior = "whitelist"
#       headers {
#         items = ["Host", "Origin"]  # 必要最小限のヘッダーのみ
#       }
#     }
#     query_strings_config {
#       query_string_behavior = "all"
#     }
#     enable_accept_encoding_gzip   = true
#     enable_accept_encoding_brotli = true
#   }
# }

# # S3向けオリジンアクセスコントロール
# resource "aws_cloudfront_origin_access_control" "s3_oac" {
#   name                              = "${local.name_prefix}-s3-oac"
#   description                       = "OAC for S3 static assets"
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }

# # CloudFront ディストリビューション
# resource "aws_cloudfront_distribution" "ecs_distribution" {
#   enabled             = true
#   is_ipv6_enabled     = false
#   comment             = "CloudFront distribution for Next.js application with SSR and static assets"
#   price_class         = "PriceClass_200"  # JAPAN
  
#   # ALBオリジン (SSR用)
#   origin {
#     domain_name = aws_lb.alb.dns_name
#     origin_id   = "${local.name_prefix}-alb-origin"
    
#     custom_origin_config {
#       http_port              = 80
#       https_port             = 443
#       origin_protocol_policy = "http-only"  # テスト用、ALBが HTTP のみの場合
#       origin_ssl_protocols   = ["TLSv1.2"]
#     }
    
#     custom_header {
#       name  = "X-Forwarded-Host"
#       value = aws_lb.alb.dns_name
#     }
#   }
  
#   # S3オリジン (静的アセット用)
#   origin {
#     domain_name              = aws_s3_bucket.frontend_assets.bucket_regional_domain_name
#     origin_id                = "${local.name_prefix}-s3-origin"
#     origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
#   }
  
#   # デフォルトのキャッシュ動作 (SSR向け)
#   default_cache_behavior {
#     allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = "${local.name_prefix}-alb-origin"
    
#     cache_policy_id = aws_cloudfront_cache_policy.minimal_cache_policy.id
    
#     viewer_protocol_policy = "redirect-to-https"
#     compress               = true
#   }
  
#   # 静的アセット用のキャッシュ動作
#   ordered_cache_behavior {
#     path_pattern     = "/_next/static/*"
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id = "${local.name_prefix}-s3-origin"
    
#     cache_policy_id = aws_cloudfront_cache_policy.static_cache_policy.id
    
#     viewer_protocol_policy = "redirect-to-https"
#     compress               = true
#   }
  
#   # 画像用のキャッシュ動作
#   ordered_cache_behavior {
#     path_pattern     = "/images/*"
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id = "${local.name_prefix}-s3-origin"
    
#     cache_policy_id = aws_cloudfront_cache_policy.static_cache_policy.id
    
#     viewer_protocol_policy = "redirect-to-https"
#     compress               = true
#   }
  
#   # 地域制限の設定
#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }
  
#   # デフォルト証明書を使用する設定
#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }
  
#   # タグ
#   tags = merge(local.common_tags, {
#     Environment = "production"
#     Name        = "${local.name_prefix}-cloudfront-distribution"
#   })
# }
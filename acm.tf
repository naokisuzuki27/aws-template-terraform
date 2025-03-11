# provider "aws" {
#   alias  = "virginia"
#   region = "us-east-1"  # バージニア北部リージョン
# }

# resource "aws_acm_certificate" "alb_cert" {
#   provider = aws.virginia
#   domain_name       = aws_lb_target_group.alb.domain_name
#   validation_method = "DNS"
# }
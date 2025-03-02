# セキュリティグループ
output "alb_sg" {
  description = "alb sg"
  value       = aws_security_group.alb_sg.id
}

# ターゲットグループARN
output "alb_sg" {
  description = "tg_gp_arn"
  value       = aws_lb_target_group.tg_gp.arn
}
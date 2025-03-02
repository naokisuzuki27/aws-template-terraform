# ターゲットグループARN
output "alb_sg" {
  description = "tg_gp_arn"
  value       = aws_lb_target_group.tg_gp.arn
}
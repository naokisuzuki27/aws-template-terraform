# モジュール定義
module "vpc" {
  source = "./vpc"
}

module "ecs" {
  source = "./ecs"
}

# リソース作成
# ALB
resource "aws_lb" "alb" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = aws_security_group.alb_sg.id
  subnets            = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]

  enable_deletion_protection = false

  tags = { merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
  })
}}

# ターゲットグループ
resource "aws_lb_target_group" "tg_gp" {
  name     = "ecs-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# リスナー
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.tg_gp.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_gp.arn
  }
}

# セキュリティグループ
resource "aws_security_group" "alb_sg" {
  name_prefix = "${local.name_prefix}-alb-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    prefix_list_ids = ["pl-58a04531"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    prefix_list_ids = ["pl-58a04531"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  tags = {
    Name = "${local.name_prefix}-alb-sg"
  }
}

# output
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
# ALB
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

# セキュリティグループ（ECSタスク用）
resource "aws_security_group" "ecs_sg" {
  name        = "${local.name_prefix}-ecstasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { merge(local.common_tags, {
    Name = "ecs_sg"
  })
}}
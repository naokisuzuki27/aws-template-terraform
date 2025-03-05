# ALB ##########################################################################################
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
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_basis_sg.id,aws_security_group.ecs_front_sg.id]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_basis_sg.id,aws_security_group.ecs_front_sg.id]
  }

  egress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_basis_sg.id,aws_security_group.ecs_front_sg.id]
  }

  tags = {
    Name = "${local.name_prefix}-alb-sg"
  }
}

# 基盤ECS用 ##########################################################################################
resource "aws_security_group" "ecs_basis_sg" {
  name        = "${local.name_prefix}-ecs-basis-sg"
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

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.rds_sg.id]
  }

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.rds_sg.id]
  }

  tags = { merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-basis-sg"
  })
}}

# サーバーレンダリングECS用 ##########################################################################################
resource "aws_security_group" "ecs_front_sg" {
  name        = "${local.name_prefix}-ecs-front-sg"
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

  ingress {
    from_port       = 3000
    to_port         = 3000
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
    Name = "${local.name_prefix}-ecs-front-sg"
  })
}}

# RDS ##########################################################################################
resource "aws_security_group" "rds_sg" {
  name        = "${local.name_prefix}-rds_sg"
  description = "Security group for rds "
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_basis_sg.id]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ecs_basis_sg.id]
  }

  tags = { merge(local.common_tags, {
    Name = "${local.name_prefix}-rds_sg"
  })
}}

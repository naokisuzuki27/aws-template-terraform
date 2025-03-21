#####################################################################
# security froup
#####################################################################
# ALB
resource "aws_security_group" "alb_sg" {
  name_prefix = "${local.name_prefix}-alb-sg"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${local.name_prefix}-alb-sg"
  }
}

# 基盤ECS用
resource "aws_security_group" "ecs_basis_sg" {
  name        = "${local.name_prefix}-ecs-basis-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-basis-sg"
  })
}

# サーバーレンダリングECS用
resource "aws_security_group" "ecs_front_sg" {
  name        = "${local.name_prefix}-ecs-front-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-front-sg"
  })
}

# RDS
resource "aws_security_group" "rds_sg" {
  name        = "${local.name_prefix}-rds_sg"
  description = "Security group for rds "
  vpc_id      = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds_sg"
  })
}
#####################################################################
# security froup rule
#####################################################################
# ALBインバウンド
resource "aws_security_group_rule" "alb_ingress_rule_443" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = ["pl-58a04531"]
}

# ALBアウトバウンド
resource "aws_security_group_rule" "alb_egress_ecs_basis_rule_3000" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "egress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  source_security_group_id   = aws_security_group.ecs_basis_sg.id
}

resource "aws_security_group_rule" "alb_egress_ecs_front_rule_3000" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "egress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  source_security_group_id   = aws_security_group.ecs_front_sg.id
}

# 基盤ECS インバウンドルール
resource "aws_security_group_rule" "ecs_basis_ingress_rule_80" {
  security_group_id = aws_security_group.ecs_basis_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id   = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "ecs_basis_ingress_rule_443" {
  security_group_id = aws_security_group.ecs_basis_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id   = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "ecs_basis_ingress_rule_3306" {
  security_group_id = aws_security_group.ecs_basis_sg.id
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id   = aws_security_group.rds_sg.id
}

resource "aws_security_group_rule" "ecs_basis_ingress_rule_3000" {
  security_group_id = aws_security_group.ecs_basis_sg.id
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  source_security_group_id   = aws_security_group.alb_sg.id
}

# 基盤ECS アウトバウンドルール
resource "aws_security_group_rule" "ecs_basis_egress_rule_80" {
  security_group_id = aws_security_group.ecs_basis_sg.id
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_basis_egress_rule_443" {
  security_group_id = aws_security_group.ecs_basis_sg.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_basis_egress_rule_3306" {
  security_group_id = aws_security_group.ecs_basis_sg.id
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id   = aws_security_group.rds_sg.id
}

# サーバーレンダリングECS インバウンド
resource "aws_security_group_rule" "ecs_front_ingress_rule_80" {
  security_group_id = aws_security_group.ecs_front_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id   = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "ecs_front_ingress_rule_443" {
  security_group_id = aws_security_group.ecs_front_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id   = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "ecs_front_ingress_rule_3000" {
  security_group_id = aws_security_group.ecs_front_sg.id
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  source_security_group_id   = aws_security_group.alb_sg.id
}

# サーバーレンダリングECS アウトバウンド
resource "aws_security_group_rule" "ecs_front_egress_rule" {
  security_group_id = aws_security_group.ecs_front_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# RDS インバウンド
resource "aws_security_group_rule" "rds_ingress_rule_3306" {
  security_group_id = aws_security_group.rds_sg.id
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id   = aws_security_group.ecs_basis_sg.id
}

# RDS アウトバウンド
resource "aws_security_group_rule" "rds_egress_rule_3306" {
  security_group_id = aws_security_group.rds_sg.id
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id   = aws_security_group.ecs_basis_sg.id
}
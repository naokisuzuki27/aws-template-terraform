# モジュール指定
module "vpc" {
  source = "./vpc"
}

module "alb" {
  source = "./alb"
}

# ECSクラスター
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = { merge(local.common_tags, {
    Name        = "${local.name_prefix}-cluster"
  })
}}

# タスク実行ロール
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# ポリシーアタッチメント
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# タスクロール（コンテナからAWSリソースへのアクセス用）
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# CloudWatch Logs グループ
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/app"
  retention_in_days = 30

  tags = {
    Environment = "${var.environment}"
  }
}

# タスク定義 (Next.js 用)
resource "aws_ecs_task_definition" "app" {
  family                   = "app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "app"
    image     = "todo-naoki/nextjs-app:latest"  # Next.js の Docker イメージ
    essential = true
    portMappings = [
      {
        containerPort = 3000  # Next.js がデフォルトで使用するポート
        hostPort      = 3000  # ECS 上でも 3000 番ポートを使用
        protocol      = "tcp"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.app.name
        "awslogs-region"        = local.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
    environment = [
      {
        name  = "ENVIRONMENT",
        value = "production"
      }
    ]
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:3000/ || exit 1"]  # Next.js アプリケーションの健康チェック
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }
  }])

  tags = { merge(local.common_tags, {
    Name        = "nextjs-app-task-definition"
    Environment = "production"
  })
}}

# ECSサービス
resource "aws_ecs_service" "app" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  platform_version = "LATEST"
  
  # サービスの自動スケーリング設定をデプロイするために必要
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 60

  network_configuration {
    subnets          = [aws_subnet.private_1a.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false  # プライベートサブネットを使用する場合
  }

  load_balancer {
    target_group_arn = [aws_lb_target_group.tg_gp.arn]
    container_name   = "app"
    container_port   = 3000  # Next.js のポートを指定
  }

  lifecycle {
    ignore_changes = [desired_count]  # Auto Scalingで調整される場合
  }

  tags = { merge(local.common_tags, {
    Name        = "nextjs-app-service"
    Environment = "production"
  })
}}

# Auto Scaling
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs-cluster.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU使用率に基づくスケーリングポリシー
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-auto-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

output "ecs_task_security_group_id" {
  description = "ID of the security group for ECS tasks"
  value       = aws_security_group.ecs_sg.id
}
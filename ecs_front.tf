#####################################################################
# ecs_cluster
#####################################################################
resource "aws_ecs_cluster" "ecs-front-cluster" {
  name = "${local.name_prefix}-front-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-front-cluster"
  })
}

#####################################################################
# task_definition
#####################################################################
resource "aws_ecs_task_definition" "front-task" {
  family                   = "front-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = templatefile(
    "./file/ecs_front.json",
    {
      ecr_repository_url = aws_ecr_repository.main.repository_url,
      image_tag          = "latest",
      region             = local.region,
      log_group_name     = aws_cloudwatch_log_group.log_front.name
    }
  )
}

#####################################################################
# ecs_service
#####################################################################
resource "aws_ecs_service" "front-service" {
  name            = "front-app-service"
  cluster         = aws_ecs_cluster.ecs-front-cluster.id
  task_definition = aws_ecs_task_definition.front-task.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  platform_version = "LATEST"
  
  # サービスの自動スケーリング設定をデプロイするために必要
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 60

  network_configuration {
    subnets          = [aws_subnet.public_1a.id]
    security_groups  = [aws_security_group.ecs_front_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_gp.arn
    container_name   = "front-app"
    container_port   = 3000  # Next.js のポートを指定
  }

  lifecycle {
    ignore_changes = [desired_count]  # Auto Scalingで調整される場合
  }

  tags = merge(local.common_tags, {
    Name        = "nextjs-app-front-service"
    Environment = "production"
  })
}

#####################################################################
# auto Scaling
#####################################################################
resource "aws_appautoscaling_target" "front-ecs_target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs-front-cluster.name}/${aws_ecs_service.front-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU使用率に基づくスケーリングポリシー
resource "aws_appautoscaling_policy" "front-ecs_policy_cpu" {
  name               = "cpu-auto-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.front-ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.front-ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.front-ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

#####################################################################
# CloudWatch Logs group
#####################################################################
resource "aws_cloudwatch_log_group" "log_front" {
  name              = "${local.name_prefix}-front-cluster"
  retention_in_days = 30

  tags = merge(local.common_tags, {
    Environment = "ecs-front-${local.environment}"
  })
}
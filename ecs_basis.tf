#####################################################################
# ecs_cluster
#####################################################################
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-cluster"
  })
}

#####################################################################
# task_definition
#####################################################################
resource "aws_ecs_task_definition" "basis-task" {
  family                   = "basis-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = file("./file/ecs_basis.json")
}

#####################################################################
# ecs_service
#####################################################################
resource "aws_ecs_service" "basis-service" {
  name            = "basis-app-service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.basis-task.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  platform_version = "LATEST"
  
  # サービスの自動スケーリング設定をデプロイするために必要
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 60

  network_configuration {
    subnets          = [aws_subnet.private_1a.id]
    security_groups  = [aws_security_group.ecs_basis_sg.id]
    assign_public_ip = false  # プライベートサブネットを使用する場合
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_gp.arn
    container_name   = "basis-app-service"
    container_port   = 3000  # Next.js のポートを指定
  }

  lifecycle {
    ignore_changes = [desired_count]  # Auto Scalingで調整される場合
  }

  tags = merge(local.common_tags, {
    Name        = "nextjs-app-basis-service"
    Environment = "production"
  })
}

#####################################################################
# auto Scaling
#####################################################################
resource "aws_appautoscaling_target" "bais_ecs_target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs-cluster.name}/${aws_ecs_service.basis-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU使用率に基づくスケーリングポリシー
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-auto-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.bais_ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.bais_ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.bais_ecs_target.service_namespace

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
resource "aws_cloudwatch_log_group" "log_basis" {
  name              = "${local.name_prefix}--basis-cluster"
  retention_in_days = 30
  tags = merge(local.common_tags, {
    Environment = "ecs-basis-${local.environment}"
  })
}
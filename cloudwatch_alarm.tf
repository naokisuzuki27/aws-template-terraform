# SNSトピック設定
resource "aws_sns_topic" "ecs_alarms" {
  name = "ecs-alarms-topic"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_slack_notification_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Role にポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda関数の作成（Slack通知用）
resource "aws_lambda_function" "slack_notification" {
  filename      = "slack_notification_lambda.zip"  # Lambda関数のコードをZIPファイルに格納する必要があります
  function_name = "ecs_alarm_slack_notification"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"

  environment {
    variables = {
      SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/your/slack/webhook/url"  # 実際のWebhook URLに置き換えてください
      SLACK_CHANNEL     = "#alerts"  # 通知を送信するSlackチャンネル
    }
  }
}

# Lambda関数をSNSトピックにサブスクライブ
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.ecs_alarms.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notification.arn
}

# Lambda関数がSNSからの通知を受け取るためのパーミッション
resource "aws_lambda_permission" "sns_to_lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notification.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.ecs_alarms.arn
}

# ECS CPUアラーム - 高使用率
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "ecs-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300  # 5分
  statistic           = "Average"
  threshold           = 80   # 80%以上でアラーム
  alarm_description   = "ECS CPUの使用率が高い状態が続いています"
  alarm_actions       = [aws_sns_topic.ecs_alarms.arn]
  ok_actions          = [aws_sns_topic.ecs_alarms.arn]

  dimensions = {
    ClusterName = "your-ecs-cluster-name"  # あなたのECSクラスター名
    ServiceName = "your-ecs-service-name"  # あなたのECSサービス名
  }
}

# ECSメモリアラーム - 高使用率
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "ecs-memory-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300  # 5分
  statistic           = "Average"
  threshold           = 80   # 80%以上でアラーム
  alarm_description   = "ECSメモリの使用率が高い状態が続いています"
  alarm_actions       = [aws_sns_topic.ecs_alarms.arn]
  ok_actions          = [aws_sns_topic.ecs_alarms.arn]

  dimensions = {
    ClusterName = "your-ecs-cluster-name"  # あなたのECSクラスター名
    ServiceName = "your-ecs-service-name"  # あなたのECSサービス名
  }
}

# タスク実行数のアラーム - 低
resource "aws_cloudwatch_metric_alarm" "ecs_task_count_low" {
  alarm_name          = "ecs-running-task-count-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 300  # 5分
  statistic           = "Average"
  threshold           = 1    # 実行中のタスクが1未満
  alarm_description   = "実行中のECSタスク数が少なすぎます"
  alarm_actions       = [aws_sns_topic.ecs_alarms.arn]
  ok_actions          = [aws_sns_topic.ecs_alarms.arn]

  dimensions = {
    ClusterName = "your-ecs-cluster-name"  # あなたのECSクラスター名
    ServiceName = "your-ecs-service-name"  # あなたのECSサービス名
  }
}

# サービス実行数のアラーム - 不一致
resource "aws_cloudwatch_metric_alarm" "ecs_service_mismatch" {
  alarm_name          = "ecs-service-desired-running-mismatch"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DesiredTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 300  # 5分
  statistic           = "Average"
  threshold           = 1    # 希望タスク数と実行タスク数が一致しない
  alarm_description   = "希望するECSタスク数と実行中のタスク数が一致していません"
  alarm_actions       = [aws_sns_topic.ecs_alarms.arn]
  ok_actions          = [aws_sns_topic.ecs_alarms.arn]

  dimensions = {
    ClusterName = "your-ecs-cluster-name"  # あなたのECSクラスター名
    ServiceName = "your-ecs-service-name"  # あなたのECSサービス名
  }
}
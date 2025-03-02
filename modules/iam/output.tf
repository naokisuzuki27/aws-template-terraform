# タスク実行ロール
output "ecs_task_execution_role" {
  description = "ecs_task_execution_role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

# タスク実行ロール
output "ecs_task_role" {
  description = "ecs_task_role"
  value       = aws_iam_role.ecs_task_role.arn
}
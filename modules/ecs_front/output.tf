output "ecs_task_security_group_id" {
  description = "ID of the security group for ECS tasks"
  value       = aws_security_group.ecs_sg.id
}
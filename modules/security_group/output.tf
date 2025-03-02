# ALB
output "alb_sg" {
  description = "alb sg"
  value       = aws_security_group.alb_sg.id
}

# ECS 基盤側
output "ecs_basis_sg" {
  description = "ecs_basis_sg"
  value       = aws_security_group.ecs_basis_sg.id
}

# ECS フロント側
output "ecs_front_sg" {
  description = "ecs_basis_sg"
  value       = aws_security_group.ecs_basis_sg.id
}

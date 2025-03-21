#####################################################################
# VPC
#####################################################################
# VPC ID
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

# IGW ID
output "internet_gateway_id" {
  description = "IGW ID"
  value       = aws_internet_gateway.inet-gw.id
}

# Public subnet ID
output "public_subnet_1a_id" {
  description = "Public Subnet 1a ID"
  value       = aws_subnet.public_1a.id
}

output "public_subnet_1c_id" {
  description = "Public Subnet 1c ID"
  value       = aws_subnet.public_1c.id
}

# Private subnet ID
output "private_subnet_1a_id" {
  description = "Private Subnet 1a ID"
  value       = aws_subnet.private_1a.id
}

output "private_subnet_1c_id" {
  description = "Private Subnet 1c ID"
  value       = aws_subnet.private_1c.id
}

# NAT Gateway ID
output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.nat_gw.id
}

# NAT EIP ID
output "nat_eip_id" {
  description = "NAT EIP ID"
  value       = aws_eip.nat_eip.id
}

# Route table ID
output "public_route_table_id" {
  description = "Public Route table ID"
  value       = aws_route_table.public_rt.id
}

output "private_route_table_id" {
  description = "Private Route table ID"
  value       = aws_route_table.private_rt.id
}

#####################################################################
# security froup
#####################################################################
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
  description = "ecs_front_sg"
  value       = aws_security_group.ecs_basis_sg.id
}

# RDS
output "rds_sg" {
  description = "rds_sg"
  value       = aws_security_group.rds_sg.id
}

#####################################################################
# iam
#####################################################################
# ECSタスク実行ロール
output "ecs_task_execution_role" {
  description = "ecs_task_execution_role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

# ECSタスクロール
output "ecs_task_role" {
  description = "ecs_task_role"
  value       = aws_iam_role.ecs_task_role.arn
}

#####################################################################
# ALB
#####################################################################
# ターゲットグループARN
output "alb_arn" {
  description = "tg_gp_arn"
  value       = aws_lb_target_group.tg_gp.arn
}

#####################################################################
# cloudfront
#####################################################################
# Clodfront Domain_name
output "cloudfront_domain_name" {
  description = "Clodfront Domain_name"
  value       = aws_cloudfront_distribution.ecs_distribution.domain_name
  
}

# Clodfront istribution ID
output "cloudfront_distribution_id" {
  description = "Clodfront istribution ID"
  value       = aws_cloudfront_distribution.ecs_distribution.id
}

#####################################################################
# s3
#####################################################################
# フロントエンドバケット名
output "frontend_bucket_name" {
  description = "s3 frontend_bucket_name"
  value       = aws_s3_bucket.frontend_bucket.id
}

# フロントエンドバケット ARN
output "frontend_bucket_arn" {
  description = "s3 frontend_bucket_arn"
  value       = aws_s3_bucket.frontend_bucket.arn
}
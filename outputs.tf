### vpc ##########################################################################

# VPCのIDを出力
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

# インターネットゲートウェイのIDを出力
output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.inet-gw.id
}

# パブリックサブネットのIDを出力
output "public_subnet_1a_id" {
  description = "Public Subnet 1a ID"
  value       = aws_subnet.public_1a.id
}

output "public_subnet_1c_id" {
  description = "Public Subnet 1c ID"
  value       = aws_subnet.public_1c.id
}

# プライベートサブネットのIDを出力
output "private_subnet_1a_id" {
  description = "Private Subnet 1a ID"
  value       = aws_subnet.private_1a.id
}

output "private_subnet_1c_id" {
  description = "Private Subnet 1c ID"
  value       = aws_subnet.private_1c.id
}

# NAT GatewayのIDを出力
output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.nat_gw.id
}

# NAT EIPのIDを出力
output "nat_eip_id" {
  description = "Elastic IP (EIP) ID for NAT Gateway"
  value       = aws_eip.nat_eip.id
}

# ルートテーブルのIDを出力
output "public_route_table_id" {
  description = "Public Route Table ID"
  value       = aws_route_table.public_rt.id
}

output "private_route_table_id" {
  description = "Private Route Table ID"
  value       = aws_route_table.private_rt.id
}

### security_group ##########################################################################
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

# RDS
output "rds_sg" {
  description = "rds_sg"
  value       = aws_security_group.rds_sg.id
}


### iam ##########################################################################
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

### alb ##########################################################################
# ターゲットグループARN
output "alb_sg" {
  description = "tg_gp_arn"
  value       = aws_lb_target_group.tg_gp.arn
}

### cloudfront ##########################################################################
output "cloudfront_domain_name" {
  description = "CloudFrontのドメイン名 - このURLからアプリケーションにアクセスできます"
  value       = aws_cloudfront_distribution.ecs_distribution.domain_name
  
}

output "cloudfront_distribution_id" {
  description = "CloudFrontディストリビューションID"
  value       = aws_cloudfront_distribution.ecs_distribution.id
}

output "origin_alb_dns_name" {
  description = "オリジンとして使用される既存ALBのDNS名"
  value       = data.aws_lb.existing_alb.dns_name
}

### s3 ##########################################################################
output "frontend_bucket_name" {
  description = "フロントエンドバケット名"
  value       = aws_s3_bucket.frontend_bucket.id
}

output "frontend_bucket_arn" {
  description = "フロントエンドバケットのARN"
  value       = aws_s3_bucket.frontend_bucket.arn
}
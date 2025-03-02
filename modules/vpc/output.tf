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
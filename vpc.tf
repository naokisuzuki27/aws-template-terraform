# AWSを定義
provider "aws" {
  region = local.region
}

# リソース作成
# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "192.168.0.0/24"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "inet-gw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

# パブリックサブネット
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.0.0/28"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet-1a"
  })
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.0.16/28"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet-1c"
  })
}

# プライベートサブネット
resource "aws_subnet" "private_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.0.128/28"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-subnet-1a"
  })
}

resource "aws_subnet" "private_1c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.0.144/28"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-subnet-1c"
  })
}

# Elastic IP (EIP) for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-eip"
  })
}

# NAT Gateway (パブリックサブネット 1a に設置)
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1a.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-gw"
  })
}

# パブリックサブネット用のルートテーブル
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inet-gw.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-route-table"
  })
}

# プライベートサブネット用のルートテーブル
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id  # NAT Gateway 経由で通信
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-route-table"
  })
}

# ルートテーブルとパブリックサブネットを関連付け
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public_rt.id
}

# ルートテーブルとプライベートサブネットを関連付け
resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private_rt.id
}
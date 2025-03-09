locals {
  project_name = "ecs-test"
  environment  = "dev"
  region       = "ap-northeast-1"
  name_prefix  = "${local.project_name}-${local.environment}"
  rds_name     = "naoki"
  rds_pass     = aws_db_subnet_group.rds_subnet_group.name
  common_tags  = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}
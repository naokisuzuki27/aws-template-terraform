locals {
  project_name = "ecs-test"
  environment  = "dev"
  region       = "ap-northeast-1"
  name_prefix  = "${local.project_name}-${local.environment}"
  common_tags  = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}
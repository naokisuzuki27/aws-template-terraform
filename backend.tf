terraform {
  backend "s3" {
    bucket         = "terraform-backet-naoki"
    key            = "ecs-20250227/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
  }
}
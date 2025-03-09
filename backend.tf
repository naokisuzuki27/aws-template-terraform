terraform {
  backend "s3" {
    bucket         = "terraform-backet-naoki2"
    key            = "tfstate/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
  }
}
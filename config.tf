terraform {
  backend "s3" {
    bucket         = "codeasone-infrastructure"
    key            = "terraform-service.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-service-tfstate"
    profile        = "codeasone"
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "codeasone"
}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket  = "codeasone-infrastructure"
    key     = "terraform-infrastructure.tfstate"
    region  = "eu-west-1"
    profile = "codeasone"
  }
}

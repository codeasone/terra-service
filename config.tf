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

data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket  = "codeasone-infrastructure"
    key     = "terraform-shared.tfstate"
    region  = "eu-west-1"
    profile = "codeasone"
  }
}

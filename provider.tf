terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.83.1"
    }
  }

  backend "s3" {
    bucket         = "jrt-terraform-state-bucket-eu-west-1"
    key            = "terraform/${var.env}/state"
    region         = "eu-west-1"
    dynamodb_table = "jrt-terraform-lock-table-eu-west-1-${var.env}"
  }
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      env = var.env
    }
  }
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.83.1"
    }
  }

  backend "s3" {
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
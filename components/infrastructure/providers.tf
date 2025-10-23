terraform {
  required_version = ">= 1.14.0-beta3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.17.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.common_tags
  }
}
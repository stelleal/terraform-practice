terraform {
#   required_version = ">= 0.14.0"
#   backend "s3" {
#     bucket = "my-bucket"
#     key    = "project/${var.ambiente}/terraform.tfstate"
#     region = "us-east-1"
#   }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
    region = var.region
}

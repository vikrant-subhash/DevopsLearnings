terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-123bkp"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform_remote_state"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}
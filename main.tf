terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "main" {
  ami           = "ami-05c8ca4485f8b138a"
  instance_type = "t2.micro"

  tags = {
    Name = "FirstterraformServer"
  }
}

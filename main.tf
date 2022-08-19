terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.env_code
  }
}


#2 Public Subnet 

resource "aws_subnet" "public" {
  count = 2

  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_cidr[count.index]

  tags = {
    Name = "${var.env_code}-public${count.index}"
  }
}

#2 Private Subnet

resource "aws_subnet" "private" {
  count = 2

  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_cidr[count.index]

  tags = {
    Name = "${var.env_code}-private${count.index}"
  }
}

#One Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.env_code
  }
}

#2 elastic Ips for 2 Nats
resource "aws_eip" "nat" {
  count = 2

  vpc = true
  tags = {
    Name = "${var.env_code}-nat${count.index}"
  }

}


#2 NAts attached to Public Subnet
resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.env_code}-${count.index}"
  }
}

#route table for Internet gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.env_code}-public"
  }
}

#2 route tables for 2 nats
resource "aws_route_table" "private" {

  count  = 2
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.env_code}-private${count.index}"
  }
}

#2 route association tables for Public Subnet and Internet gateway
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#2 route asspciation tables between 2 Nat and 2 Private subnet
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Public Security groups
resource "aws_security_group" "Public_SG" {
  name        = "TF_PubSG"
  description = "TF_PubSG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Public_SG"
  }
}

#Private Secuity groups
resource "aws_security_group" "Private_SG" {
  name        = "TF_PvtSG"
  description = "TF_PvtSG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Private_SG"
  }
}

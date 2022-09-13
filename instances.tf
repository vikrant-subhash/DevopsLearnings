resource "aws_instance" "public" {
  ami                         = "ami-06489866022e12a14"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "terraform_key_pair"
  vpc_security_group_ids      = [aws_security_group.Public_SG.id]
  subnet_id                   = aws_subnet.public[1].id

  tags = {
    Name = "${var.env_code}-public"
  }

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

resource "aws_instance" "private" {
  ami                    = "ami-06489866022e12a14"
  instance_type          = "t3.micro"
  key_name               = "terraform_key_pair"
  vpc_security_group_ids = [aws_security_group.Private_SG.id]
  subnet_id              = aws_subnet.private[0].id

  tags = {
    Name = "${var.env_code}-private"
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
    cidr_blocks = [var.vpc_cidr]
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

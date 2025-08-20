provider "aws" {
  region = "ap-southeast-2"
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_vpc" "terraform_vpc" {
  cidr_block = "192.168.0.0/24"
  tags = {
    Name = "terraform_vpc"
  }
}

resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    Name = "terraform_igw"
  }
}

resource "aws_route_table" "terraform_route_table" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_igw.id
  }
}

resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.terraform_route_table.id
}
resource "aws_security_group" "terraform_security_group" {
  vpc_id = aws_vpc.terraform_vpc.id

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.242.28.54/32"]
    }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "terraform_security_group"
    }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = "192.168.0.0/25"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_instance" "terraform_ec2" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.terraform_security_group.id]
  tags = {
    Name = "terraform_ec2_instance"
  }
}
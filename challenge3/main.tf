# challenge3/main.tf

provider "aws" {
  region = "ap-southeast-2"
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

  tags = {
    Name = "terraform_route_table"
  }
}

resource "aws_subnet" "terraform_subnet" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "192.168.0.0/24"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "terraform_subnet"
  }
}

resource "aws_route_table_association" "terraform_subnet" {
  subnet_id      = aws_subnet.terraform_subnet.id
  route_table_id = aws_route_table.terraform_route_table.id
}
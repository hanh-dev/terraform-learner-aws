provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_vpc" "terraform_vpc" {
  cidr_block = "192.168.0.0/24"

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "terraform_subnets" {
  count = 2
  availability_zone = [
    "ap-southeast-2a",
    "ap-southeast-2b"
  ][count.index]
  cidr_block = [
    "192.168.0.0/25",
    "192.168.0.128/25"
  ][count.index]
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "${var.vpc_name}-subnet-${count.index + 1}"
  }
}
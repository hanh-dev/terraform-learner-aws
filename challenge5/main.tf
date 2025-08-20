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
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.terraform_vpc.id
  cidr_block = "192.168.0.0/25"
  availability_zone = "ap-southeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_name
  }
}

resource "aws_security_group" "public_sg" {
    vpc_id = aws_vpc.terraform_vpc.id
    ingress {
        description = "HTTP access"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH access"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.terraform_vpc.id
  cidr_block = "192.168.0.128/25"
  availability_zone = "ap-southeast-2a"
  tags = {
    Name = var.private_subnet_name
  }
}

resource "aws_db_subnet_group" "app_db_subnet_group" {
  name       = "app-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id]

  tags = {
    Name = "App DB Subnet Group"
  }
}

resource "aws_security_group" "rds_sg" {
    vpc_id = aws_vpc.terraform_vpc.id
    
    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        security_groups = [aws_security_group.public_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_internet_gateway" "public_gateway" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = var.public_gateway_name
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_gateway.id
  }
}

resource "aws_instance" "app_server" {
  ami = data.aws_ami.latest_amazon_linux.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "AppServer"
  }
}

resource "aws_route_table_association" "route_associate" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_db_instance" "app_db" {
    allocated_storage = 20
    engine = "postgres"
    instance_class = "db.t3.micro"
    vpc_security_group_ids = [ aws_security_group.rds_sg.id ]
    username = "admin"
    password = "password"
    skip_final_snapshot = true
}
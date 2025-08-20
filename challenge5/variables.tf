variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "terraform_vpc"
}

variable "public_subnet_name" {
  description = "Name of the public subnet"
  type = string
  default = "terraform_public_subnet"
}

variable "public_gateway_name" {
  description = "Name of the public internet gateway"
  type = string
  default = "terraform_public_gateway"
}

variable "private_subnet_name" {
  description = "Name of the private subnet"
  type = string
  default = "terraform_private_subnet"
}
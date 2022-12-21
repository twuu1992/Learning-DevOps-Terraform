// VPC, Internet Gateway and Subnet
resource "aws_vpc" "vpc_user_project" {
  cidr_block           = "172.16.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    "Name" = "vpc-user-app"
  }
}

resource "aws_internet_gateway" "user_gw" {
  vpc_id = aws_vpc.vpc_user_project.id
  tags = {
    Name = "user-app-internet-gateway"
  }
}

resource "aws_route_table" "user_rt" {
  vpc_id = aws_vpc.vpc_user_project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.user_gw.id
  }

  tags = {
    "Name" = "user-app-route-table"
  }
}

locals {
  subnets = [
    {
      availability_zone = "ap-southeast-2a",
      cidr_block        = "172.16.0.0/20"
    },
    {
      availability_zone = "ap-southeast-2b",
      cidr_block        = "172.16.16.0/20"
    },
    {
      availability_zone = "ap-southeast-2c",
      cidr_block        = "172.16.32.0/20"
    }
  ]
}

resource "aws_subnet" "subnets" {
  for_each                = { for index, subnet in local.subnets : index => subnet }
  vpc_id                  = aws_vpc.vpc_user_project.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    "Name" = "user-app-subnet-${each.value.availability_zone}"
  }
}

module "app_alb" {
  source = "./modules/elb"

  sg_id_list     = [aws_security_group.alb_sg.id]
  subnet_id_list = values(aws_subnet.subnets)[*].id
  vpc_id         = aws_vpc.vpc_user_project.id
}

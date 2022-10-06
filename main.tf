// TODO: migrate backend to TF cloud for furture CI/CD pipeline
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.32.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

// VPC, Internet Gateway and Subnet
resource "aws_vpc" "vpc_user_project" {
  cidr_block       = "172.16.0.0/16"
  instance_tenancy = "default"

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

resource "aws_subnet" "subnet_user_project" {
  for_each                = { for subnet in local.subnets : subnet.availability_zone => subnet }
  vpc_id                  = aws_vpc.vpc_user_project.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    "Name" = "user-app-subnet-${each.value.availability_zone}"
  }
}

// EC2 instances
resource "aws_instance" "my_user_app" {
  ami           = var.ami
  instance_type = var.instance_type
}

resource "aws_instance" "my_user_db" {
  ami           = var.ami
  instance_type = var.instance_type
}

// Security Groups
resource "aws_security_group" "app" {
  name        = "my-user-app-${var.infra_env}-sg"
  description = "Security Group for the User Application"
  vpc_id      = aws_vpc.vpc_user_project.id

  tags = {
    Name      = "my-user-app-${var.infra_env}-sg"
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "mongodb" {
  name        = "my-user-mongodb-${var.infra_env}-sg"
  description = "Security Group for the User Database"
  vpc_id      = aws_vpc.vpc_user_project.id

  tags = {
    Name      = "my-user-mongodb-${var.infra_env}-sg"
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "my-user-alb-${var.infra_env}-sg"
  description = "Security Group for the ALB"
  vpc_id      = aws_vpc.vpc_user_project.id

  ingress {
    description = "Http traffic to the frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc_user_project.cidr_block]
  }

  ingress {
    description = "Http traffic to the API service"
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc_user_project.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "my-user-alb-${var.infra_env}-sg"
    ManagedBy = "terraform"
  }
}

// SG Rules
// egress
resource "aws_security_group_rule" "app_public_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "mongodb_public_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mongodb.id
}

// ingress
// APP
resource "aws_security_group_rule" "app_ssh_local_in" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip_addr]
  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_backend_in" {
  type              = "ingress"
  from_port         = 4000
  to_port           = 4000
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip_addr]
  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_http_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip_addr]
  security_group_id = aws_security_group.app.id
}

//MONGODB
resource "aws_security_group_rule" "mongodb_ssh_local_in" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip_addr]
  security_group_id = aws_security_group.mongodb.id
}

resource "aws_security_group_rule" "mongodb_ports_ec2_in" {
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.my_user_app.public_ip}/32"]
  security_group_id = aws_security_group.mongodb.id
}

// ELB
resource "aws_lb" "user_app" {
  name               = "alb-user-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for subnet in aws_subnet.subnet_user_project : subnet.id]

  tags = {
    "Name" = "alb-user-app"
  }
}

resource "aws_lb_target_group" "frontend" {
  name     = "alb-tg-user-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_user_project.id
}

resource "aws_lb_target_group" "backend" {
  name     = "alb-tg-user-api"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_user_project.id
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.user_app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.user_app.arn
  port              = 4000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

// OUTPUT
output "alb_DNS" {
  value = aws_lb.user_app.dns_name
}

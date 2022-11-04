// TODO: migrate backend to TF cloud for furture CI/CD pipeline
terraform {
  cloud {
    organization = "aws_devops"

    workspaces {
      name = "jenkins-pipeline"
    }
  }
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

// EC2 instances
resource "aws_instance" "my_user_app" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = "EC2-Key-Pair"
  monitoring    = true

  subnet_id              = values(aws_subnet.subnets)[0].id
  vpc_security_group_ids = [aws_security_group.app.id]

  tags = {
    "Name" = "my-user-app"
  }
}

resource "aws_instance" "my_user_db" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = "EC2-Key-Pair"
  monitoring    = true

  subnet_id              = values(aws_subnet.subnets)[0].id
  vpc_security_group_ids = [aws_security_group.mongodb.id]

  tags = {
    "Name" = "my-user-db"
  }
}

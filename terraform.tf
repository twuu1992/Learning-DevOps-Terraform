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
      version = "~> 3.28.0"
    }
  }
}

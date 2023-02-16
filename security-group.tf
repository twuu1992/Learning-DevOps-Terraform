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

resource "aws_security_group" "lb_sg" {
  name        = "my-user-lb-${var.infra_env}-sg"
  description = "Security Group for the ALB"
  vpc_id      = aws_vpc.vpc_user_project.id

  ingress {
    description = "Http traffic to the frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_addr]
  }

  ingress {
    description = "Http traffic to the API service"
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_addr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "my-user-lb-${var.infra_env}-sg"
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

resource "aws_security_group_rule" "app_backend_local_in" {
  type              = "ingress"
  from_port         = 4000
  to_port           = 4000
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip_addr]
  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_http_local_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip_addr]
  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_jenkins_all_traffic_in" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.jenkins_ip_addr]
  security_group_id = aws_security_group.app.id
  description = "All traffic from jenkins node"
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

resource "aws_security_group_rule" "jenkins_ssh_local_in" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.jenkins_ip_addr]
  security_group_id = aws_security_group.app.id
}

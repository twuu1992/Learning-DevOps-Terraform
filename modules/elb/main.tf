// ELB
resource "aws_lb" "user_app" {
  name               = "alb-user-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.sg_id_list
  subnets            = var.subnet_id_list

  tags = {
    "Name" = "alb-user-app"
  }
}

resource "aws_lb_target_group" "frontend" {
  name     = "alb-tg-user-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "backend" {
  name     = "alb-tg-user-api"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
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

resource "aws_lb" "application_lb" {

  name = "enterprise-alb"

  internal = false

  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.public.id,
    aws_subnet.public_subnet_b.id
  ]

  enable_deletion_protection = false

  tags = {
    Name        = "enterprise-alb"
    Project     = "Enterprise-AWS-DevOps-Platform"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application_lb.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.springboot_tg.arn
  }
}
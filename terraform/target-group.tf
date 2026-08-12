resource "aws_lb_target_group" "springboot_tg" {
  name        = "enterprise-target-group"
  port        = 8083
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "enterprise-target-group"
    Project     = "Enterprise-AWS-DevOps-Platform"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
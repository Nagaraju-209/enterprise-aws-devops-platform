resource "aws_lb" "application_lb" {

  name = "enterprise-alb"

  internal = false

  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.public.id,
    aws_subnet.private.id
  ]

  enable_deletion_protection = false

  tags = {
    Name        = "enterprise-alb"
    Project     = "Enterprise-AWS-DevOps-Platform"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
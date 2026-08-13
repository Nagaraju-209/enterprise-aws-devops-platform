resource "aws_security_group" "alb_sg" {
  name        = "enterprise-alb-sg"
  description = "Security Group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"

    from_port = 80
    to_port   = 80

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name        = "enterprise-alb-sg"
    Project     = "Enterprise-AWS-DevOps-Platform"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
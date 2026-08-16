resource "aws_security_group" "public_sg" {

  name        = "public-security-group"
  description = "Security group for public EC2 instances"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "public-security-group"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_egress_rule" "public_outbound" {

  security_group_id = aws_security_group.public_sg.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"

  description = "Allow all outbound traffic"
}

resource "aws_security_group" "app_sg" {

  name        = "application-security-group"
  description = "Security group for application EC2 instances"

  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "application-security-group"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_port" {

  security_group_id = aws_security_group.app_sg.id

  referenced_security_group_id = aws_security_group.alb_sg.id

  from_port = 8083
  to_port   = 8083

  ip_protocol = "tcp"

  description = "Allow application traffic from ALB"
}

resource "aws_vpc_security_group_egress_rule" "app_outbound" {

  security_group_id = aws_security_group.app_sg.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"

  description = "Allow all outbound traffic"
}
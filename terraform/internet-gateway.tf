resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "enterprise-devops-igw"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }
}

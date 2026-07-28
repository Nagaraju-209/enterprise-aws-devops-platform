resource "aws_key_pair" "main" {
  key_name   = "enterprise-devops-key"
  public_key = file("${path.module}/../keys/enterprise-devops-key.pub")

  tags = {
    Name        = "enterprise-devops-key"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }
}
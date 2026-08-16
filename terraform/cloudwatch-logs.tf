resource "aws_cloudwatch_log_group" "application" {

  name              = "/enterprise-aws-devops-platform/application"
  retention_in_days = 30

  tags = {
    Name        = "enterprise-aws-devops-platform-application-logs"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }
}
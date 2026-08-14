resource "aws_sns_topic" "monitoring_alerts" {

  name = "enterprise-devops-monitoring-alerts"

  tags = {
    Name        = "enterprise-devops-monitoring-alerts"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }
}

resource "aws_sns_topic_subscription" "monitoring_email" {

  topic_arn = aws_sns_topic.monitoring_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email

  lifecycle {
    ignore_changes = [endpoint]
  }
}
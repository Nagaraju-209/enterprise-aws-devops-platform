resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {

  alarm_name = "enterprise-devops-ec2-high-cpu"

  alarm_description = "Alarm when EC2 CPU utilization remains above 80%"

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    InstanceId = aws_instance.app_server.id
  }

  statistic          = "Average"
  period             = 300
  evaluation_periods = 2

  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "enterprise-devops-ec2-high-cpu"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }
}
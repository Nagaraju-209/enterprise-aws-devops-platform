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

  alarm_actions = [
    aws_sns_topic.monitoring_alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.monitoring_alerts.arn
  ]

  tags = {
    Name        = "enterprise-devops-ec2-high-cpu"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# ALB MONITORING
# ============================================================

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {

  alarm_name = "enterprise-devops-alb-unhealthy-targets"

  alarm_description = "Alarm when one or more ALB targets become unhealthy"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"

  dimensions = {
    LoadBalancer = aws_lb.application_lb.arn_suffix
    TargetGroup  = aws_lb_target_group.springboot_tg.arn_suffix
  }

  statistic          = "Maximum"
  period             = 60
  evaluation_periods = 2

  threshold           = 0
  comparison_operator = "GreaterThanThreshold"

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.monitoring_alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.monitoring_alerts.arn
  ]

  tags = {
    Name        = "enterprise-devops-alb-unhealthy-targets"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }
}


resource "aws_cloudwatch_metric_alarm" "alb_no_healthy_targets" {

  alarm_name = "enterprise-devops-alb-no-healthy-targets"

  alarm_description = "Alarm when the ALB has no healthy application targets"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HealthyHostCount"

  dimensions = {
    LoadBalancer = aws_lb.application_lb.arn_suffix
    TargetGroup  = aws_lb_target_group.springboot_tg.arn_suffix
  }

  statistic          = "Minimum"
  period             = 60
  evaluation_periods = 2

  threshold           = 1
  comparison_operator = "LessThanThreshold"

  treat_missing_data = "breaching"

  alarm_actions = [
    aws_sns_topic.monitoring_alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.monitoring_alerts.arn
  ]

  tags = {
    Name        = "enterprise-devops-alb-no-healthy-targets"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }
}


resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {

  alarm_name = "enterprise-devops-alb-5xx-errors"

  alarm_description = "Alarm when the ALB returns more than 5 HTTP 5xx errors"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"

  dimensions = {
    LoadBalancer = aws_lb.application_lb.arn_suffix
  }

  statistic          = "Sum"
  period             = 300
  evaluation_periods = 1

  threshold           = 5
  comparison_operator = "GreaterThanThreshold"

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.monitoring_alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.monitoring_alerts.arn
  ]

  tags = {
    Name        = "enterprise-devops-alb-5xx-errors"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }
}


resource "aws_cloudwatch_metric_alarm" "alb_high_response_time" {

  alarm_name = "enterprise-devops-alb-high-response-time"

  alarm_description = "Alarm when ALB target response time exceeds 2 seconds"

  namespace   = "AWS/ApplicationELB"
  metric_name = "TargetResponseTime"

  dimensions = {
    LoadBalancer = aws_lb.application_lb.arn_suffix
    TargetGroup  = aws_lb_target_group.springboot_tg.arn_suffix
  }

  extended_statistic = "p95"
  period             = 300
  evaluation_periods = 2

  threshold           = 2
  comparison_operator = "GreaterThanThreshold"

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.monitoring_alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.monitoring_alerts.arn
  ]

  tags = {
    Name        = "enterprise-devops-alb-high-response-time"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }
}
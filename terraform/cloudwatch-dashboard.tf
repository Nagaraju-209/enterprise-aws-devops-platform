resource "aws_cloudwatch_dashboard" "enterprise" {

  dashboard_name = "enterprise-aws-devops-platform"

  dashboard_body = jsonencode({
    widgets = [

      # ==========================================================
      # EC2 CPU UTILIZATION
      # ==========================================================
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title = "EC2 CPU Utilization"

          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              aws_instance.app_server.id
            ]
          ]

          period = 300
          stat   = "Average"
          region = var.aws_region

          view    = "timeSeries"
          stacked = false

          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },

      # ==========================================================
      # ALB HEALTH
      # ==========================================================
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title = "ALB Target Health"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HealthyHostCount",
              "LoadBalancer",
              aws_lb.application_lb.arn_suffix,
              "TargetGroup",
              aws_lb_target_group.springboot_tg.arn_suffix
            ],
            [
              ".",
              "UnHealthyHostCount",
              ".",
              ".",
              ".",
              "."
            ]
          ]

          period = 60
          stat   = "Maximum"
          region = var.aws_region

          view    = "timeSeries"
          stacked = false
        }
      },

      # ==========================================================
      # ALB REQUEST COUNT
      # ==========================================================
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title = "ALB Request Count"

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              aws_lb.application_lb.arn_suffix
            ]
          ]

          period = 300
          stat   = "Sum"
          region = var.aws_region

          view    = "timeSeries"
          stacked = false
        }
      },

      # ==========================================================
      # ALB HTTP ERRORS
      # ==========================================================
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title = "ALB HTTP Errors"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_ELB_4XX_Count",
              "LoadBalancer",
              aws_lb.application_lb.arn_suffix
            ],
            [
              ".",
              "HTTPCode_ELB_5XX_Count",
              ".",
              "."
            ]
          ]

          period = 300
          stat   = "Sum"
          region = var.aws_region

          view    = "timeSeries"
          stacked = false
        }
      },

      # ==========================================================
      # TARGET RESPONSE TIME
      # ==========================================================
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          title = "ALB Target Response Time"

          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              aws_lb.application_lb.arn_suffix,
              "TargetGroup",
              aws_lb_target_group.springboot_tg.arn_suffix
            ]
          ]

          period = 300
          stat   = "Average"
          region = var.aws_region

          view    = "timeSeries"
          stacked = false
        }
      },

      # ==========================================================
      # ALB 5XX / TARGET RESPONSE
      # ==========================================================
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6

        properties = {
          title = "ALB 5XX Errors"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_ELB_5XX_Count",
              "LoadBalancer",
              aws_lb.application_lb.arn_suffix
            ]
          ]

          period = 300
          stat   = "Sum"
          region = var.aws_region

          view    = "timeSeries"
          stacked = false
        }
      }

    ]
  })
}
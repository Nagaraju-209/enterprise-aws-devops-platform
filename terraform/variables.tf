variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "alert_email" {
  description = "Email address for CloudWatch monitoring notifications"
  type        = string
  sensitive   = true
}
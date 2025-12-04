terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "alarm_email" {
  description = "Email address for billing alarm notifications"
  type        = string
}

locals {
  name_prefix = "Anshul_Sharma"
}

resource "aws_sns_topic" "billing_topic" {
  name = "${locals.name_prefix}_billing_topic"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.billing_topic.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# CloudWatch Billing Alarm (currency: USD)
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "${locals.name_prefix}_billing_over_threshold"
  alarm_description   = "Alert when estimated charges exceed threshold"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600   # 6 hours
  statistic           = "Maximum"
  threshold           = 1.5     # approximate ~₹100; adjust as needed
  treat_missing_data  = "notBreaching"

  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [aws_sns_topic.billing_topic.arn]
  ok_actions    = [aws_sns_topic.billing_topic.arn]
}

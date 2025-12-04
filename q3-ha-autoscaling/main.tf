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
  region = var.region
}

variable "region" {
  type        = string
  default     = "ap-south-1"
  description = "Region"
}

variable "vpc_id" {
  type        = string
  description = "Existing VPC ID from Q1"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs from Q1 for ALB"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs from Q1 for ASG"
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair"
}

locals {
  name_prefix = "Anshul_Sharma"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Security group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "${locals.name_prefix}_alb_sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${locals.name_prefix}_alb_sg"
  }
}

# Security group for EC2 instances
resource "aws_security_group" "app_sg" {
  name        = "${locals.name_prefix}_app_sg"
  description = "App instances SG (only ALB can reach them)"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Optional SSH for debugging from your IP range (keep closed in production)
  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["YOUR_IP/32"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${locals.name_prefix}_app_sg"
  }
}

# Target group
resource "aws_lb_target_group" "tg" {
  name     = "${locals.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${locals.name_prefix}_tg"
  }
}

# ALB
resource "aws_lb" "alb" {
  name               = "${locals.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${locals.name_prefix}_alb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Launch template for app instances
resource "aws_launch_template" "app_lt" {
  name_prefix   = "${locals.name_prefix}_lt_"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(file("${path.module}/user_data.sh"))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${locals.name_prefix}_app_instance"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  name                      = "${locals.name_prefix}_asg"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 2
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 90

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  tag {
    key                 = "Name"
    value               = "${locals.name_prefix}_asg_instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

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

############################
# VARIABLES (FROM Q1)
############################

variable "region" {
  default = "ap-south-1"
}

variable "vpc_id" {
  default = "vpc-0f50c694b5d9a253b"
}

variable "public_subnet_ids" {
  type    = list(string)
  default = [
    "subnet-0adc778612111f3e0",
    "subnet-06553c08cba504aab"
  ]
}

variable "private_subnet_ids" {
  type    = list(string)
  default = [
    "subnet-04a4cf2a70064d816",
    "subnet-0b1fcdcb66244f693"
  ]
}

variable "key_name" {
  default = "anshul-keypair"
}

locals {
  name_prefix = "Anshul_Sharma"
}

############################
# AMI
############################

data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

############################
# SECURITY GROUPS
############################

# ✅ ALB Security Group
resource "aws_security_group" "alb_sg" {
  name   = "${local.name_prefix}_alb_sg"
  vpc_id = var.vpc_id

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
    Name = "${local.name_prefix}_alb_sg"
  }
}

# ✅ EC2 Security Group
resource "aws_security_group" "ec2_sg" {
  name   = "${local.name_prefix}_asg_ec2_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "${local.name_prefix}_asg_ec2_sg"
  }
}

############################
# ✅ LOAD BALANCER (NO UNDERSCORES!)
############################

resource "aws_lb" "alb" {
  name               = "anshul-sharma-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${local.name_prefix}_alb"
  }
}

############################
# ✅ TARGET GROUP (NO UNDERSCORES!)
############################

resource "aws_lb_target_group" "tg" {
  name     = "anshul-sharma-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
  }

  tags = {
    Name = "${local.name_prefix}_tg"
  }
}

############################
# LISTENER
############################

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

############################
# LAUNCH TEMPLATE
############################

resource "aws_launch_template" "lt" {
  name_prefix   = "${local.name_prefix}_lt"
  image_id      = data.aws_ami.amazon_linux2.id
  instance_type = "t3.micro"
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = filebase64("${path.module}/user_data.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.name_prefix}_asg_instance"
    }
  }
}

############################
# AUTO SCALING GROUP
############################

resource "aws_autoscaling_group" "asg" {
  desired_capacity = 2
  max_size         = 3
  min_size         = 2

  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}_asg_instance"
    propagate_at_launch = true
  }
}

############################
# OUTPUTS
############################

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.asg.name
}

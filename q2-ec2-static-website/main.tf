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
# Variables
############################

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

# From Q1 – your VPC
variable "vpc_id" {
  description = "VPC ID created in Q1"
  type        = string
  default     = "vpc-0f50c694b5d9a253b"
}

# From Q1 – choose first public subnet
variable "public_subnet_id" {
  description = "Public subnet ID from Q1 for EC2 instance"
  type        = string
  default     = "subnet-0adc778612111f3e0"
}

# Update this to an existing EC2 key pair name in ap-south-1
variable "key_name" {
  description = "EC2 key pair name (create in AWS console before apply)"
  type        = string
  default     = "anshul-keypair"
}

# For best practice, set this to your own IP CIDR like x.x.x.x/32
variable "ssh_ingress_cidr" {
  description = "CIDR allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

locals {
  name_prefix = "Anshul_Sharma"
}

############################
# AMI – Amazon Linux 2
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
# Security Group
############################

resource "aws_security_group" "web_sg" {
  name        = "${local.name_prefix}_web_sg"
  description = "Security group for Nginx resume website"
  vpc_id      = var.vpc_id

  # HTTP from anywhere
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH from limited CIDR
  ingress {
    description = "Allow SSH from admin IP range"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  # Egress – allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}_web_sg"
  }
}

############################
# EC2 Instance
############################

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux2.id
  instance_type               = "t3.micro" # Free Tier eligible
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "${local.name_prefix}_resume_web"
  }
}

############################
# Outputs
############################

output "ec2_instance_id" {
  description = "ID of the EC2 instance hosting the resume site"
  value       = aws_instance.web.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.web.public_dns
}

output "security_group_id" {
  description = "Security Group ID used for the EC2 instance"
  value       = aws_security_group.web_sg.id
}

# ✅ Q3 – High Availability Architecture (ALB + Auto Scaling + Private Subnets)

---

## 📌 Task Overview

This task enhances the Q2 architecture by implementing a **highly available web setup** using an **Application Load Balancer (ALB)** and an **Auto Scaling Group (ASG)**. EC2 instances are deployed in **private subnets**, while the **ALB is internet-facing in public subnets**, ensuring scalability, fault tolerance, and security.

---

## 🧠 High Availability Architecture & Traffic Flow (5–8 Lines)

An internet-facing **Application Load Balancer (ALB)** is deployed in two public subnets across different Availability Zones. Incoming traffic from users first reaches the ALB over HTTP. The ALB forwards the traffic to a **Target Group**, which is attached to an **Auto Scaling Group (ASG)**. The ASG launches and manages EC2 instances across **two private subnets** for high availability. If one instance or AZ fails, the ALB automatically routes traffic to the healthy instance. The ASG also automatically scales the number of EC2 instances based on desired capacity.

---

## 🛠️ AWS Resources Used

- Application Load Balancer (ALB)
- Target Group
- ALB Listener (HTTP 80)
- Launch Template
- Auto Scaling Group (ASG)
- EC2 Instances (t3.micro)
- Public & Private Subnets (from Q1)
- Security Groups
- Nginx Web Server
- Terraform (Infrastructure as Code)

---

## 🌐 Infrastructure Details

- **VPC:** `vpc-0f50c694b5d9a253b`
- **Public Subnets (ALB):**
  - `subnet-0adc778612111f3e0`
  - `subnet-06553c08cba504aab`
- **Private Subnets (ASG EC2):**
  - `subnet-04a4cf2a70064d816`
  - `subnet-0b1fcdcb66244f693`
- **Instance Type:** `t3.micro` (Free Tier eligible)
- **Protocol:** HTTP (Port 80)

---

## 🌍 Accessing the Application

After `terraform apply`, Terraform outputs:

```text
alb_dns_name = <your-alb-dns-name>
asg_name     = <your-asg-name>

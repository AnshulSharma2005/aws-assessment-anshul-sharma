# ✅ Q1 – AWS VPC Networking & Subnetting (Terraform)

---

## 📌 Overview
This task demonstrates the design and implementation of a secure and scalable AWS networking architecture using Terraform. A custom VPC was created with public and private subnets, an Internet Gateway for inbound access, and a NAT Gateway for secure outbound internet access from private subnets. All resources follow the mandatory naming convention with the prefix `Anshul_Sharma_`.

---

## 🛠️ AWS Services Used
- Amazon VPC  
- Public & Private Subnets  
- Internet Gateway (IGW)  
- NAT Gateway  
- Route Tables  
- Elastic IP  
- Terraform (Infrastructure as Code)

---

## 🧠 Architecture Design Explanation (4–6 lines)

A custom VPC with a `/16` CIDR block was created and divided into two public and two private subnets across two Availability Zones for high availability. The public subnets host internet-facing resources and the NAT Gateway. An Internet Gateway provides inbound and outbound access for public subnets. The private subnets route outbound internet traffic securely through the NAT Gateway. Separate route tables were created to enforce controlled routing.

---

## 🌐 Network CIDR Allocation

| Resource | CIDR Block |
|----------|------------|
| VPC | `10.0.0.0/16` |
| Public Subnet A | `10.0.1.0/24` |
| Public Subnet B | `10.0.2.0/24` |
| Private Subnet A | `10.0.11.0/24` |
| Private Subnet B | `10.0.12.0/24` |

### ✅ CIDR Justification:
- `/16` allows up to **65,536 IPs** for scalability.
- Each `/24` subnet supports **256 IPs**, ideal for workload separation.
- Public subnets are used for internet-facing traffic.
- Private subnets are isolated and use NAT for outbound access only.

---

## ✅ Terraform Deployment Outputs (Proof)

```text
VPC ID:
vpc-0f50c694b5d9a253b

Public Subnets:
- subnet-0adc778612111f3e0
- subnet-06553c08cba504aab

Private Subnets:
- subnet-04a4cf2a70064d816
- subnet-0b1fcdcb66244f693

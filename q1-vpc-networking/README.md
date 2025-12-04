I designed a dedicated VPC to logically isolate the lab environment and keep all resources under a single network boundary. I chose 10.0.0.0/16 as the VPC CIDR to have enough room for multiple subnets. Two public subnets are spread across different AZs for high availability of internet-facing components (IGW, NAT, ALB later). Two private subnets (also multi-AZ) host internal workloads that should not have direct internet exposure. An Internet Gateway is attached to give public subnets outbound/inbound internet access, while a single NAT Gateway in a public subnet provides controlled outbound-only internet access for the private subnets via dedicated route tables.

CIDR ranges used & rationale

VPC: 10.0.0.0/16 – large enough address space for future expansion.

Public subnet 1: 10.0.1.0/24 (AZ1) – clearly separated from private ranges.

Public subnet 2: 10.0.2.0/24 (AZ2) – second AZ for HA.

Private subnet 1: 10.0.11.0/24 (AZ1) – distinct /24 range reserved for internal workloads.

Private subnet 2: 10.0.12.0/24 (AZ2) – mirrors private subnet 1 in another AZ.

This structure avoids overlapping CIDRs and makes it easy to identify public vs private ranges by the second octet (1–2 public, 11–12 private).
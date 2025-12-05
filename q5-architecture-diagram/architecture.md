# Q5 – Scalable Web Application Architecture (draw.io)

---

## 📌 Architecture Explanation
This architecture supports **10,000 concurrent users** using scalable AWS services.  
Traffic enters through **Route53 + ALB**, then hits an **Auto Scaling Group** across multiple AZs.  
Private subnets host the backend and RDS database.  
Redis (ElastiCache) improves performance and reduces DB load.  
AWS WAF provides security, while CloudWatch ensures observability.  
S3 + CloudFront handle static content delivery globally.

---

## 🖼 Architecture Diagram
![Architecture Diagram](diagram/architecture.png)



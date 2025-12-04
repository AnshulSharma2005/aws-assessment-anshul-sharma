#!/bin/bash
# Update packages
yum update -y

# Install Nginx
amazon-linux-extras install nginx1 -y || yum install -y nginx

# Enable and start Nginx
systemctl enable nginx
systemctl start nginx

# Simple static resume page
cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Anshul Sharma - Resume</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; background: #f7f7f7; }
    .container { max-width: 900px; margin: 0 auto; background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
    h1 { margin-bottom: 0; }
    h2 { margin-top: 30px; border-bottom: 1px solid #eee; padding-bottom: 5px; }
    .section { margin-top: 15px; }
    ul { padding-left: 20px; }
    .header-info { color: #555; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Anshul Sharma</h1>
    <p class="header-info">Email: your.email@example.com | Phone: +91-XXXXXXXXXX | Location: India</p>

    <h2>Summary</h2>
    <p>A passionate software developer with experience in C++, Java, Python, and AWS cloud. Interested in backend engineering, DevOps, and scalable system design.</p>

    <h2>Skills</h2>
    <ul>
      <li>Programming: C++, Java, Python, JavaScript</li>
      <li>Cloud: AWS (VPC, EC2, S3, IAM, CloudWatch)</li>
      <li>Web: HTML, CSS, basic React</li>
      <li>Tools: Git, GitHub, Linux, Terraform (IaC)</li>
    </ul>

    <h2>Experience / Projects</h2>
    <ul>
      <li><strong>AWS VPC & EC2 Lab:</strong> Designed secure network with public/private subnets, NAT Gateway, and hosted a static resume on EC2 using Nginx.</li>
      <li><strong>Project 2:</strong> Add your other project details here.</li>
    </ul>

    <h2>Education</h2>
    <p>Candidate for B.Tech (add your branch/university/year here).</p>
  </div>
</body>
</html>
EOF

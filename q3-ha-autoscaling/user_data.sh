#!/bin/bash
yum update -y
amazon-linux-extras install nginx1 -y || yum install -y nginx
systemctl enable nginx
systemctl start nginx

cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>Anshul Sharma - HA Web App</title>
</head>
<body>
  <h1>High Availability Web App</h1>
  <p>Served from an Auto Scaling Group behind an Application Load Balancer.</p>
</body>
</html>
EOF

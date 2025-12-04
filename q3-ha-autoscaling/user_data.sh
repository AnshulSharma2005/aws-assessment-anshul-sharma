#!/bin/bash
yum update -y
amazon-linux-extras install nginx1 -y || yum install -y nginx

systemctl enable nginx
systemctl start nginx

cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>Anshul Sharma - HA Resume Site</title>
  <meta charset="UTF-8" />
</head>
<body>
  <h1>Highly Available Resume Site</h1>
  <p>This instance is part of an Auto Scaling Group behind an ALB.</p>
</body>
</html>
EOF

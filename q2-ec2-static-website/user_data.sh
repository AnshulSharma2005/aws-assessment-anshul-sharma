#!/bin/bash
yum update -y

# Install Nginx
amazon-linux-extras install nginx1 -y || yum install -y nginx

systemctl enable nginx
systemctl start nginx

cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>Anshul Sharma - Resume</title>
  <meta charset="UTF-8" />
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; }
    h1 { color: #333; }
  </style>
</head>
<body>
  <h1>Anshul Sharma</h1>
  <h2>Resume</h2>
  <p>Put your resume content here (summary, skills, experience, projects, etc.).</p>
</body>
</html>
EOF

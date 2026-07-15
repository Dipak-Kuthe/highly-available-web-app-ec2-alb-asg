#!/bin/bash
# ---------------------------------------------------------------------------
# EC2 bootstrap script for the Highly Available Web Application
# Installs and starts Apache, then serves a page that identifies the instance
# so you can confirm the ALB is distributing traffic across instances.
# ---------------------------------------------------------------------------
set -euo pipefail

# Update packages and install the web server (Amazon Linux 2023)
dnf update -y
dnf install -y httpd

# Enable and start Apache
systemctl enable --now httpd

# Fetch instance metadata (IMDSv2)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

# Write a simple landing page
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>Highly Available Web App</title></head>
<body style="font-family: sans-serif; text-align: center; padding-top: 60px;">
  <h1>Highly Available Web Application</h1>
  <p>Served by instance: <strong>$INSTANCE_ID</strong></p>
  <p>Availability Zone: <strong>$AZ</strong></p>
</body>
</html>
EOF

echo "Bootstrap complete."

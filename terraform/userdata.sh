#!/bin/bash

set -eux

dnf update -y

dnf install -y \
    docker \
    git \
    unzip \
    wget

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o "/tmp/awscliv2.zip"

cd /tmp
unzip awscliv2.zip
./aws/install

# Install Amazon CloudWatch Agent
wget -q \
    https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm \
    -O /tmp/amazon-cloudwatch-agent.rpm

dnf install -y /tmp/amazon-cloudwatch-agent.rpm

# CloudWatch Agent configuration
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'EOF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "EnterpriseAWS/EC2",
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "/"
        ]
      }
    }
  }
}
EOF

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

systemctl enable amazon-cloudwatch-agent

# Verification
docker --version
git --version
aws --version

systemctl status amazon-cloudwatch-agent --no-pager

echo "Bootstrap completed successfully."
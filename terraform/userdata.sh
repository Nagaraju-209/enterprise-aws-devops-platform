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

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"

cd /tmp
unzip awscliv2.zip
./aws/install

docker --version
git --version
aws --version

echo "Bootstrap completed successfully."
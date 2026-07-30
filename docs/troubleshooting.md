# Troubleshooting Guide

## Overview

This document records common issues encountered while developing and deploying the Enterprise AWS DevOps Platform.

The troubleshooting steps are based on real implementation experience and provide practical solutions for common DevOps problems.

---

# Table of Contents

1. Terraform Issues
2. AWS CLI Issues
3. Docker Issues
4. Spring Boot Issues
5. GitHub Actions Issues
6. Amazon ECR Issues
7. EC2 Deployment Issues
8. SSH Connectivity Issues
9. Health Check Issues
10. General Debugging Tips

---

# 1. Terraform Issues

## Problem

Terraform fails during infrastructure provisioning.

Example:

```text
Error creating resource...
```

### Possible Causes

- Invalid AWS credentials
- Incorrect region
- Existing AWS resources
- Missing IAM permissions

### Resolution

Verify:

```bash
aws configure

terraform init

terraform validate

terraform plan
```

Ensure the configured AWS region matches the Terraform provider configuration.

---

# 2. AWS CLI Issues

## Problem

AWS CLI commands fail.

Example:

```text
Unable to locate credentials
```

### Resolution

Verify AWS configuration.

```bash
aws configure list

aws sts get-caller-identity
```

Confirm:

- Access Key
- Secret Key
- Region

---

# 3. Docker Issues

## Problem

Docker service not available.

Example:

```text
Cannot connect to the Docker daemon
```

### Resolution

Check Docker status.

```bash
sudo systemctl status docker

sudo systemctl start docker

sudo systemctl enable docker
```

Verify installation.

```bash
docker --version
```

---

## Amazon Linux 2023 Package Conflict

### Problem

Docker installation failed with:

```text
curl-minimal conflicts with curl
```

### Resolution

Install packages without replacing `curl-minimal`.

```bash
sudo dnf install -y docker git unzip wget
```

Then start Docker.

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

---

# 4. Spring Boot Issues

## Java Version Mismatch

### Problem

Build failed due to Java version incompatibility.

The project was initially created with Java 21, while the local environment used Java 17.

### Resolution

Update the `pom.xml` file:

```xml
<java.version>17</java.version>
```

Verify:

```bash
java -version

mvn -version
```

---

# 5. GitHub Actions Issues

## Workflow Build Failure

### Possible Causes

- Maven compilation errors
- Missing dependencies
- Incorrect workflow syntax

### Resolution

Check:

- GitHub Actions logs
- `pom.xml`
- Workflow YAML syntax

Validate locally:

```bash
mvn clean package
```

before pushing changes.

---

# 6. Amazon ECR Issues

## Authentication Failed

Example:

```text
AccessDeniedException
```

### Cause

EC2 IAM Role lacked permission to access Amazon ECR.

### Resolution

Attach the managed IAM policy:

```
AmazonEC2ContainerRegistryReadOnly
```

Verify:

```bash
aws ecr get-login-password --region ap-south-1
```

Expected:

```
Authentication token returned successfully.
```

---

# 7. EC2 Deployment Issues

## Container Not Running

### Check

```bash
docker ps -a
```

Inspect logs:

```bash
docker logs enterprise-app
```

Restart:

```bash
docker restart enterprise-app
```

---

## Image Pull Failure

Verify Docker login.

```bash
aws ecr get-login-password --region ap-south-1 \
| docker login \
--username AWS \
--password-stdin <ECR_REGISTRY>
```

Then:

```bash
docker pull <IMAGE>
```

---

# 8. SSH Connectivity Issues

## GitHub Actions Cannot Connect

### Verify

Security Group:

- Port 22 open

GitHub Secret:

```
EC2_HOST
```

Ensure the value contains only the EC2 public IP address.

Verify manually:

```bash
ssh ec2-user@<EC2_PUBLIC_IP>
```

---

# 9. Health Check Failure

## Problem

GitHub Actions reports:

```text
curl: (7)
Failed to connect
```

### Possible Causes

- Container failed to start
- Wrong application port
- Spring Boot startup error
- Application still initializing

### Resolution

Check:

```bash
docker logs enterprise-app

docker ps

curl http://localhost:8083/health
```

If using Spring Boot Actuator:

```bash
curl http://localhost:8083/actuator/health
```

---

# 10. General Debugging Tips

Useful commands:

Docker:

```bash
docker ps

docker images

docker logs enterprise-app
```

AWS:

```bash
aws sts get-caller-identity
```

Terraform:

```bash
terraform validate

terraform plan
```

GitHub Actions:

- Review workflow logs
- Verify repository secrets
- Check workflow YAML

---

# Lessons Learned

This project provided practical experience in:

- Infrastructure as Code
- Docker containerization
- GitHub Actions CI/CD
- Amazon ECR
- Amazon EC2
- IAM permissions
- Linux troubleshooting
- Deployment automation
- Health validation
- Production debugging

---

# Summary

Building a production-style DevOps platform involves more than writing infrastructure code.

Troubleshooting, debugging, and resolving deployment issues are critical engineering skills.

The issues documented here reflect real-world implementation challenges and the solutions used to successfully automate infrastructure provisioning and application deployment.
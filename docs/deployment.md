# Deployment Guide

## Overview

This document describes how the Enterprise AWS DevOps Platform is deployed on AWS.

The project uses Infrastructure as Code (Terraform), Docker containers, Amazon Elastic Container Registry (ECR), Amazon EC2, and GitHub Actions to automate application deployment.

The deployment process is fully automated after every successful push to the GitHub repository.

---

# Deployment Architecture

```
Developer
     │
Git Push
     │
     ▼
GitHub Actions
     │
     ▼
Build Spring Boot
     │
     ▼
Build Docker Image
     │
     ▼
Amazon ECR
     │
     ▼
SSH into EC2
     │
     ▼
Pull Latest Image
     │
     ▼
Replace Running Container
     │
     ▼
Health Check
     │
     ▼
Live Application
```

---

# Deployment Prerequisites

The following components must be available before deployment.

## AWS

- AWS Account
- IAM User
- IAM Role
- Amazon EC2 Instance
- Amazon ECR Repository

---

## Local Development

Required software:

- Git
- Java 17
- Maven
- Docker Desktop
- AWS CLI
- Terraform

---

## GitHub

Repository Secrets:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION
- ECR_REGISTRY
- ECR_REPOSITORY
- EC2_HOST
- EC2_USERNAME
- EC2_SSH_KEY

---

# Infrastructure Deployment

Infrastructure is provisioned using Terraform.

Resources include:

- VPC
- Public Subnet
- Private Subnet
- Internet Gateway
- NAT Gateway
- Route Tables
- Elastic IP
- Security Groups
- IAM Role
- EC2 Instance

Deployment commands:

```bash
terraform init

terraform plan

terraform apply
```

---

# Application Deployment

The Spring Boot application is packaged using Maven.

Command:

```bash
mvn clean package
```

Output:

```
target/*.jar
```

---

# Docker Build

Docker packages the application.

Example:

```bash
docker build -t enterprise-aws-devops-platform .
```

Verify:

```bash
docker images
```

---

# Amazon ECR Deployment

Authenticate Docker:

```bash
aws ecr get-login-password --region ap-south-1 \
| docker login \
--username AWS \
--password-stdin <ECR_REGISTRY>
```

Push Image:

```bash
docker push <IMAGE_TAG>
```

---

# Automated Deployment

Deployment is automatically triggered after every push to GitHub.

The workflow performs:

1. Checkout Source
2. Build Application
3. Build Docker Image
4. Push Docker Image
5. Connect to EC2
6. Pull Latest Image
7. Replace Existing Container
8. Verify Deployment
9. Health Check

No manual deployment is required.

---

# Deployment Verification

Verify Docker container:

```bash
docker ps
```

Verify images:

```bash
docker images
```

Verify application:

```bash
curl http://localhost:8083/health
```

---

# Rollback Strategy

If deployment fails:

1. Identify the previous image tag.
2. Pull the previous image.
3. Stop the failed container.
4. Start the previous version.

Example:

```bash
docker stop enterprise-app

docker rm enterprise-app

docker run -d \
--name enterprise-app \
-p 8083:8083 \
<PREVIOUS_IMAGE_TAG>
```

---

# Security Considerations

The deployment follows security best practices.

- IAM Roles are used instead of hardcoded credentials.
- AWS credentials are stored in GitHub Secrets.
- Docker images are stored in Amazon ECR.
- SSH access uses private key authentication.
- Security Groups restrict inbound traffic.
- Application runs inside Docker containers.

---

# Deployment Validation

Every deployment performs validation.

Checks include:

- Docker image successfully pulled
- Docker container started
- Application responds successfully
- Health endpoint returns HTTP 200

If any validation fails, the GitHub Actions workflow reports the deployment as failed.

---

# Benefits

This deployment process provides:

- Fully automated deployments
- Consistent application delivery
- Reduced human error
- Version-controlled infrastructure
- Immutable Docker images
- Production-style deployment workflow
- Easy rollback
- Cloud-native deployment

---

# Summary

The Enterprise AWS DevOps Platform demonstrates a complete deployment lifecycle using modern DevOps practices.

The combination of Terraform, Docker, GitHub Actions, Amazon ECR, and Amazon EC2 provides a reliable, repeatable, and automated deployment solution suitable for production-style environments.
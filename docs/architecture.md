# Enterprise AWS DevOps Platform Architecture

## Overview

The Enterprise AWS DevOps Platform demonstrates a complete production-style DevOps workflow built on AWS. It automates infrastructure provisioning, application containerization, Continuous Integration, Continuous Deployment, and cloud-based application hosting.

The project follows modern DevOps practices by combining Infrastructure as Code (Terraform), containerization (Docker), cloud services (AWS), and automated deployment (GitHub Actions).

---

# High-Level Architecture

```
                    Developer
                        │
                 Git Push to GitHub
                        │
                        ▼
               GitHub Repository
                        │
                        ▼
               GitHub Actions CI/CD
                        │
        ┌───────────────┼────────────────┐
        │               │                │
        ▼               ▼                ▼
 Build Spring Boot   Build Docker    Push Image
      Project           Image       to Amazon ECR
        │                                │
        └────────────────────────────────┘
                         │
                         ▼
                  SSH into EC2
                         │
                         ▼
              Pull Docker Image
                         │
                         ▼
             Stop Existing Container
                         │
                         ▼
             Start New Container
                         │
                         ▼
             Spring Boot Application
                         │
                         ▼
                 REST API Available
```

---

# Architecture Components

The project consists of the following major components.

## 1. Developer Workstation

The developer writes code locally.

Responsibilities include:

- Writing application code
- Managing Git branches
- Running local testing
- Committing changes
- Pushing code to GitHub

---

## 2. GitHub Repository

GitHub serves as the central version control system.

Responsibilities:

- Source code management
- Branch management
- Pull Requests
- Workflow triggering
- Code history

Repository Structure:

- Application Source
- Terraform Code
- GitHub Actions Workflow
- Documentation
- Screenshots

---

## 3. GitHub Actions

GitHub Actions provides Continuous Integration and Continuous Deployment.

Pipeline stages include:

- Checkout Source Code
- Setup Java
- Build Spring Boot Application
- Execute Maven Build
- Configure AWS Credentials
- Login to Amazon ECR
- Build Docker Image
- Push Docker Image
- SSH into EC2
- Pull Latest Image
- Deploy Application
- Perform Health Check

---

## 4. Amazon Elastic Container Registry (ECR)

Amazon ECR stores Docker images securely.

Responsibilities:

- Image versioning
- Image storage
- Image distribution
- Secure image retrieval

Images are tagged using:

- latest
- build number
- Git commit SHA

---

## 5. Amazon EC2

Amazon EC2 hosts the application.

Responsibilities:

- Running Docker Engine
- Pulling images from ECR
- Running application containers
- Serving application traffic

The EC2 instance automatically receives updated Docker images after every successful deployment.

---

## 6. Docker

Docker packages the Spring Boot application into a portable container.

Advantages:

- Consistent runtime environment
- Easy deployment
- Lightweight packaging
- Platform independence

---

## 7. Spring Boot Application

The backend application exposes REST APIs.

Current APIs include:

- Home Endpoint
- Health Endpoint
- Version Endpoint
- Employee APIs

The application runs on:

Port:

8083

---

# Infrastructure Components

Infrastructure is provisioned using Terraform.

Provisioned resources include:

- VPC
- Public Subnet
- Private Subnet
- Internet Gateway
- NAT Gateway
- Elastic IP
- Route Tables
- Security Groups
- IAM Role
- IAM Instance Profile
- EC2 Instance

---

# Security Architecture

Security measures include:

- IAM Roles instead of static credentials
- SSH Key Authentication
- Security Groups
- Private Networking
- Docker Image Isolation
- Amazon ECR Authentication

---

# Deployment Flow

1. Developer pushes code.
2. GitHub Actions starts automatically.
3. Spring Boot project is built.
4. Docker image is created.
5. Docker image is pushed to Amazon ECR.
6. GitHub Actions connects to EC2.
7. EC2 pulls the latest Docker image.
8. Existing container is replaced.
9. Health checks validate deployment.
10. Updated application becomes available.

---

# Benefits of this Architecture

- Infrastructure as Codes
- Automated CI/CD
- Immutable Docker Images
- Cloud Native Deployment
- Version Controlled Infrastructure
- Fully Automated Deployment
- Production-style Workflow
- Easily Scalable
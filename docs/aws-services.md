# AWS Services Used

## Overview

The Enterprise AWS DevOps Platform leverages multiple AWS services to build a secure, scalable, and automated deployment pipeline.

Each AWS service plays a specific role in infrastructure provisioning, application deployment, security, networking, and container management.

---

# AWS Architecture

```
                    AWS Cloud
-------------------------------------------------------

                IAM
                 │
                 ▼
Developer → GitHub Actions
                 │
                 ▼
             Amazon ECR
                 │
                 ▼
            Amazon EC2
                 │
                 ▼
             Docker Engine
                 │
                 ▼
      Spring Boot Application

Infrastructure Provisioned Using Terraform

VPC
├── Public Subnet
├── Private Subnet
├── Internet Gateway
├── NAT Gateway
├── Route Tables
├── Security Groups
└── Elastic IP

-------------------------------------------------------
```

---

# 1. Amazon VPC

## Purpose

Amazon Virtual Private Cloud (VPC) provides an isolated virtual network for AWS resources.

---

## Why VPC?

- Network isolation
- Secure communication
- Custom IP addressing
- Routing control

---

## Components Used

- VPC
- Public Subnet
- Private Subnet
- Route Tables
- Internet Gateway
- NAT Gateway

---

## Benefits

- Secure architecture
- Flexible networking
- Better traffic management

---

# 2. Public Subnet

## Purpose

Hosts internet-facing resources.

Used for:

- EC2 Instance
- Internet access

---

# 3. Private Subnet

## Purpose

Reserved for backend resources requiring no direct internet access.

Although currently unused by the application, it demonstrates a production-ready network design and supports future expansion, such as databases or internal services.

---

# 4. Internet Gateway

## Purpose

Enables communication between the VPC and the public internet.

Responsibilities:

- Outbound internet access
- Inbound public traffic

---

# 5. NAT Gateway

## Purpose

Allows instances in private subnets to access the internet without exposing them publicly.

Benefits:

- Increased security
- Controlled outbound connectivity

---

# 6. Route Tables

## Purpose

Define how traffic is routed inside the VPC.

Responsibilities:

- Public subnet routing
- Private subnet routing
- Internet Gateway association
- NAT Gateway routing

---

# 7. Elastic IP

## Purpose

Provides a static public IPv4 address.

Benefits:

- Stable public endpoint
- Persistent IP across instance restarts (when associated)

---

# 8. Security Groups

## Purpose

Act as virtual firewalls for EC2 instances.

Configured Rules:

Inbound:

- SSH (22)
- HTTP (80) *(optional if used)*
- Application Port (8083)

Outbound:

- Allow all outbound traffic

---

# 9. IAM (Identity and Access Management)

## Purpose

Controls access to AWS resources.

Used Components:

- IAM User
- IAM Role
- IAM Instance Profile

---

## Why IAM Roles?

The EC2 instance accesses Amazon ECR using an IAM Role instead of storing AWS access keys on the server.

Benefits:

- Improved security
- Temporary credentials
- Easier permission management

---

# 10. Amazon EC2

## Purpose

Hosts the application.

Responsibilities:

- Docker Engine
- Pull images from Amazon ECR
- Run Spring Boot container
- Serve REST APIs

Operating System:

Amazon Linux 2023

---

# 11. Amazon Elastic Container Registry (ECR)

## Purpose

Stores Docker images securely.

Responsibilities:

- Image repository
- Image versioning
- Secure distribution

Image Tags:

- latest
- build-<GitHub Run Number>
- <Git Commit SHA>

Benefits:

- Centralized storage
- Integration with IAM
- Efficient image management

---

# 12. AWS CLI

## Purpose

Enables command-line interaction with AWS services.

Used for:

- ECR authentication
- Identity verification
- Resource management

Example Commands:

```bash
aws sts get-caller-identity

aws ecr get-login-password
```

---

# Security Best Practices

This project follows several AWS security best practices:

- IAM Roles instead of long-lived credentials
- Least privilege permissions
- GitHub Secrets for sensitive values
- Security Groups to restrict network access
- Containerized application deployment
- Private networking design
- Encrypted communication with AWS APIs

---

# AWS Services Summary

| Service | Purpose |
|----------|---------|
| Amazon VPC | Network isolation |
| Public Subnet | Internet-facing resources |
| Private Subnet | Future backend services |
| Internet Gateway | Internet connectivity |
| NAT Gateway | Secure outbound internet |
| Route Tables | Traffic routing |
| Elastic IP | Static public IP |
| Security Groups | Instance firewall |
| IAM | Authentication & authorization |
| Amazon EC2 | Application hosting |
| Amazon ECR | Docker image registry |
| AWS CLI | AWS automation |

---

# Interview Questions

### Why did you use Amazon ECR instead of Docker Hub?

- Native AWS integration
- IAM authentication
- Better security
- Faster access from EC2
- Simplified permissions

---

### Why did you use IAM Roles?

IAM Roles eliminate the need to store AWS access keys on the EC2 instance and provide temporary credentials managed by AWS.

---

### Why use a VPC?

A VPC provides network isolation, custom routing, and security controls for cloud resources.

---

### Why use Docker on EC2?

Docker provides a consistent runtime environment, simplifies deployments, and ensures the application behaves the same across environments.

---

# Lessons Learned

This project provided hands-on experience with:

- AWS Networking
- IAM
- EC2
- Amazon ECR
- Infrastructure as Code
- Docker Deployment
- Secure Cloud Architecture
- CI/CD Integration

---

# Summary

The Enterprise AWS DevOps Platform integrates multiple AWS services to create a secure, automated, and production-style deployment environment.

Each AWS service contributes to scalability, reliability, security, and operational efficiency, demonstrating practical cloud engineering and DevOps skills.
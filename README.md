# Enterprise AWS DevOps Platform

> Production-grade AWS infrastructure built using Terraform following DevOps best practices.

---

## Project Overview

This project demonstrates how to provision a production-style AWS networking infrastructure using Infrastructure as Code (IaC) with Terraform.

The goal is to build a scalable, secure, and modular cloud environment that will later host containerized applications deployed through a complete CI/CD pipeline.

This repository is being developed module by module, following industry best practices used by DevOps engineers.

---

## Current Progress

| Module | Status |
|---------|--------|
| Module 1 – AWS Account & IAM | ✅ Completed |
| Module 2 – AWS CLI & Terraform Setup | ✅ Completed |
| Module 3 – AWS Networking (VPC) | ✅ Completed |
| Module 4 – Security & Compute | 🚧 Coming Soon |
| Module 5 – Docker Deployment | ⏳ Planned |
| Module 6 – GitHub Actions CI/CD | ⏳ Planned |
| Module 7 – Amazon ECR | ⏳ Planned |
| Module 8 – Monitoring | ⏳ Planned |

---

# Technology Stack

- AWS
- Terraform
- AWS CLI
- Git
- GitHub
- Linux (WSL)

---

# AWS Services Used

- Amazon VPC
- Public Subnet
- Private Subnet
- Internet Gateway
- NAT Gateway
- Elastic IP
- Route Tables
- Route Table Associations
- IAM

---

# Project Structure

```text
enterprise-aws-devops-platform/
│
├── terraform/
│   ├── provider.tf
│   ├── versions.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── vpc.tf
│   ├── subnet.tf
│   ├── internet-gateway.tf
│   ├── route-table.tf
│   ├── nat-gateway.tf
│   └── terraform.tfstate (ignored)
│
├── diagrams/
│
├── screenshots/
│   └── module-3-networking/
│
├── docs/
│
├── scripts/
│
├── README.md
└── .gitignore
```

---

# Infrastructure Created

## Networking

- Custom VPC
- Public Subnet
- Private Subnet
- Internet Gateway
- NAT Gateway
- Elastic IP
- Public Route Table
- Private Route Table
- Route Table Associations

---

# Network Architecture

```text
                         Internet
                             │
                     Internet Gateway
                             │
                  Public Route Table
                  0.0.0.0/0 → IGW
                             │
                     Public Subnet
                    10.0.1.0/24
                             │
                    NAT Gateway + EIP
                             ▲
                             │
                  Private Route Table
                  0.0.0.0/0 → NAT
                             │
                    Private Subnet
                    10.0.2.0/24
```

---

# Terraform Resources Used

- aws_vpc
- aws_subnet
- aws_internet_gateway
- aws_route_table
- aws_route
- aws_route_table_association
- aws_nat_gateway
- aws_eip

---

# Terraform Commands Used

## Initialize Terraform

```bash
terraform init
```

### Format Configuration

```bash
terraform fmt
```

### Validate Configuration

```bash
terraform validate
```

### Preview Infrastructure

```bash
terraform plan
```

### Provision Infrastructure

```bash
terraform apply
```

### Destroy Infrastructure

```bash
terraform destroy
```

---

# Outputs

After deployment Terraform provides:

- VPC ID
- Public Subnet ID
- Private Subnet ID
- Internet Gateway ID
- NAT Gateway ID

---

# Screenshots

The following screenshots are available inside:

```
screenshots/module-3-networking/
```

Recommended screenshots:

- VPC
- Subnets
- Route Tables
- Public Route Table
- Private Route Table
- Internet Gateway
- NAT Gateway
- Elastic IP
- Terraform Apply Output

---

# Learning Objectives

Through this project I learned how to:

- Build AWS infrastructure using Terraform
- Design production-ready VPC networking
- Create public and private subnets
- Configure Internet Gateway
- Configure NAT Gateway
- Manage Route Tables
- Implement Infrastructure as Code (IaC)
- Follow Terraform best practices
- Organize Terraform projects using modular files

---

# Upcoming Modules

- Security Groups
- EC2 Provisioning
- IAM Roles
- User Data Scripts
- Docker Deployment
- Amazon ECR
- GitHub Actions CI/CD
- Monitoring & Logging
- Production Deployment

---

# Author

**Dandu Rama Siva Naga Raju**

- GitHub: https://github.com/Nagaraju-209
- LinkedIn: https://linkedin.com/in/dandu-rama-siva-naga-raju
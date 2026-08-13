# 🚀 Enterprise AWS DevOps Platform

A production-inspired DevOps project that demonstrates Infrastructure as Code (Terraform), containerization (Docker), Continuous Integration and Continuous Deployment (GitHub Actions), and automated deployment on AWS.

The platform provisions cloud infrastructure, builds a Spring Boot application, packages it into Docker containers, stores images in Amazon ECR, and automatically deploys them to an Amazon EC2 instance after every successful GitHub push.

![Java](https://img.shields.io/badge/Java-17-orange)

![Spring Boot](https://img.shields.io/badge/SpringBoot-3.x-brightgreen)

![Docker](https://img.shields.io/badge/Docker-Containerized-blue)

![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)

![AWS](https://img.shields.io/badge/AWS-Cloud-orange)

![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI/CD-blue)

![License](https://img.shields.io/badge/License-MIT-green)

## 🌟 Project Highlights

- Automated Infrastructure Provisioning using Terraform
- Secure AWS Networking with VPC
- Spring Boot REST API
- Docker Multi-stage Builds
- Amazon Elastic Container Registry (ECR)
- GitHub Actions CI/CD Pipeline
- Automatic Deployment to Amazon EC2
- Health Check Validation
- Docker Cleanup Automation
- Production-inspired Deployment Workflow

## 🏗️ Architecture

![Architecture](diagrams/architecture.png)

### Architecture Overview

The platform provisions AWS infrastructure using Terraform, builds and packages a Spring Boot application with Maven and Docker, stores container images in Amazon ECR, and automatically deploys them to an EC2 instance through GitHub Actions. Every deployment concludes with health checks and automated Docker cleanup.

## 🛠️ Technology Stack

| Category | Technology |
|----------|------------|
| Language | Java 17 |
| Framework | Spring Boot 3 |
| Build Tool | Maven |
| Containerization | Docker |
| Cloud Provider | AWS |
| Infrastructure as Code | Terraform |
| CI/CD | GitHub Actions |
| Container Registry | Amazon ECR |
| Operating System | Amazon Linux 2023 |
| Version Control | Git & GitHub |

## ☁️ AWS Services Used

- Amazon EC2
- Amazon ECR
- Amazon VPC
- Internet Gateway
- NAT Gateway
- Route Tables
- Security Groups
- IAM
- Elastic IP

## 🔗 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | / | Welcome endpoint |
| GET | /health | Health check |
| GET | /version | Application version |
| GET | /api/employees | List employees |
| POST | /api/employees | Create employee |

## 🚀 Local Setup

```bash
git clone https://github.com/Nagaraju-209/enterprise-aws-devops-platform.git

cd enterprise-aws-devops-platform

cd app/springboot-app

mvn clean package

java -jar target/*.jar
```

## 🚀 Deployment

Every push to the `feature/github-actions-cicd` branch triggers the GitHub Actions workflow.


The pipeline automatically:

1. Builds the Spring Boot application.
2. Creates a Docker image.
3. Pushes the image to Amazon ECR.
4. Connects to the EC2 instance via SSH.
5. Pulls the latest image.
6. Deploys the updated container.
7. Performs a health check.
8. Cleans up unused Docker resources.
9. Publishes a deployment summary.

## 📸 Screenshots

### GitHub Actions Pipeline

![Pipeline](screenshots/github-actions.png)

### Amazon EC2

![EC2](screenshots/ec2.png)

### Amazon ECR

![ECR](screenshots/ecr.png)

### Application Running

![Application](screenshots/application.png)

## ✨ Features

- Infrastructure provisioning using Terraform
- Secure AWS networking
- Dockerized Spring Boot application
- Automated CI/CD with GitHub Actions
- Amazon ECR integration
- Automated EC2 deployment
- Health check validation
- Docker cleanup automation
- Immutable Docker image tagging
- Workflow summaries



## 📚 Documentation

- [Architecture](docs/architecture.md)
- [CI/CD Workflow](docs/ci-cd-workflow.md)
- [Deployment Guide](docs/deployment.md)
- [Troubleshooting](docs/troubleshooting.md)
- [AWS Services](docs/aws-services.md)
- [Project Structure](docs/project-structure.md)
- [Pipeline Optimization](docs/pipeline-optimization.md)
- [ALB Architecture](docs/alb-architecture.md)

## 💼 Skills Demonstrated

- Infrastructure as Code
- Cloud Networking
- AWS Services
- Docker Containerization
- Continuous Integration
- Continuous Deployment
- GitHub Actions
- Terraform
- Linux Administration
- Secure Cloud Deployment
- DevOps Automation

## 🚀 Future Enhancements

- Application Load Balancer (ALB)
- HTTPS using ACM
- Auto Scaling Group
- Amazon EKS
- Prometheus & Grafana Monitoring
- CloudWatch Integration
- Blue/Green Deployment

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

**Dandu Rama Siva Naga Raju**

- LinkedIn: https://www.linkedin.com/in/dandu-rama-siva-naga-raju/
- GitHub: https://github.com/Nagaraju-209
# GitHub Actions CI/CD Workflow

## Overview

This project implements a fully automated Continuous Integration and Continuous Deployment (CI/CD) pipeline using GitHub Actions.

The pipeline automates the complete software delivery lifecycle—from source code changes to deployment on an Amazon EC2 instance.

The workflow eliminates manual deployment tasks, ensuring every successful code change is automatically built, containerized, published, deployed, and verified.

---

# CI/CD Pipeline Architecture

```
Developer
    │
    ▼
Git Push
    │
    ▼
GitHub Repository
    │
    ▼
GitHub Actions Workflow
    │
    ├── Checkout Source Code
    ├── Setup Java 17
    ├── Build Spring Boot Application
    ├── Upload Build Artifact
    ├── Configure AWS Credentials
    ├── Login to Amazon ECR
    ├── Generate Image Tags
    ├── Build Docker Image
    ├── Push Docker Image
    ├── SSH into EC2
    ├── Login to Amazon ECR
    ├── Pull Latest Image
    ├── Stop Existing Container
    ├── Remove Existing Container
    ├── Start New Container
    ├── Verify Deployment
    └── Health Check
```

---

# Continuous Integration (CI)

Continuous Integration automatically validates every code change.

The CI process includes:

- Source Code Checkout
- Java Environment Setup
- Maven Dependency Resolution
- Spring Boot Build
- Artifact Generation
- Docker Image Build

Benefits:

- Detects build failures early
- Ensures consistent builds
- Produces deployable artifacts
- Reduces manual effort

---

# Continuous Deployment (CD)

After a successful build, the deployment pipeline executes automatically.

Deployment includes:

- Authenticate with AWS
- Authenticate with Amazon ECR
- Push Docker Image
- Connect to EC2
- Pull Updated Image
- Replace Existing Container
- Validate Application Health

Benefits:

- Zero manual deployment
- Consistent deployments
- Faster software delivery
- Reduced deployment errors

---

# Workflow Stages

## Stage 1 — Source Checkout

GitHub Actions checks out the latest version of the repository.

Purpose:

- Access project source code
- Prepare build environment

---

## Stage 2 — Java Environment

The workflow installs Java 17.

Purpose:

- Compile the Spring Boot application
- Execute Maven commands

---

## Stage 3 — Build Application

The application is compiled using Maven.

Command:

```bash
mvn clean package
```

Generated Artifact:

```
target/*.jar
```

---

## Stage 4 — Docker Image Build

Docker packages the Spring Boot application.

Benefits:

- Consistent runtime
- Portable deployment
- Immutable application image

---

## Stage 5 — Configure AWS Credentials

GitHub Actions authenticates with AWS using repository secrets.

Secrets used:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION

---

## Stage 6 — Login to Amazon ECR

The workflow authenticates Docker with Amazon ECR.

Purpose:

- Push container images securely

---

## Stage 7 — Docker Image Tagging

Each build generates multiple image tags.

Current strategy:

- latest
- build-<GitHub Run Number>
- <Git Commit SHA>

Example:

```
latest
build-42
80ee0d0
```

Benefits:

- Easy rollback
- Version tracking
- Immutable deployments

---

## Stage 8 — Push Docker Image

Docker image is uploaded to Amazon ECR.

Purpose:

- Central image repository
- Secure image distribution

---

## Stage 9 — SSH into EC2

GitHub Actions connects securely to the EC2 instance.

Authentication:

- SSH Private Key
- IAM Role
- Security Group

---

## Stage 10 — Deploy Container

Deployment steps:

1. Login to Amazon ECR
2. Pull latest image
3. Stop running container
4. Remove existing container
5. Start new container

Container Name:

```
enterprise-app
```

Application Port:

```
8083
```

---

## Stage 11 — Deployment Verification

The workflow validates deployment by checking:

- Docker container status
- Running image
- Container logs

---

## Stage 12 — Health Check

The final stage verifies the application.

Example:

```bash
curl http://localhost:8083/health
```

If the health check fails, the workflow reports the deployment as failed.

---

# Security

The workflow avoids hardcoded credentials.

Sensitive values are stored in GitHub Secrets.

Examples:

- AWS Credentials
- EC2 Host
- EC2 Username
- SSH Private Key
- ECR Repository

---

# Benefits of the Pipeline

- Fully Automated
- Repeatable
- Version Controlled
- Secure
- Production Ready
- Fast Deployments
- Easy Rollback
- Reduced Human Error

---

# Workflow Outcome

Every successful push automatically performs:

- Build
- Test
- Package
- Containerize
- Publish
- Deploy
- Validate

No manual deployment steps are required.

---

# Summary

This CI/CD implementation demonstrates modern DevOps practices by integrating GitHub Actions, Docker, Amazon ECR, Amazon EC2, and Spring Boot into a complete automated deployment pipeline.

The workflow ensures every successful code change is automatically delivered to the target environment while maintaining consistency, reliability, and deployment quality.
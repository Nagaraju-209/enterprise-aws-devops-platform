# Project Structure

## Overview

The Enterprise AWS DevOps Platform follows a modular repository structure that separates application code, infrastructure, automation, documentation, and supporting resources.

The organization improves maintainability, scalability, and collaboration while following common DevOps and software engineering practices.

---

# Repository Structure

```
enterprise-aws-devops-platform/
│
├── .github/
│   └── workflows/
│       └── github-actions.yml
│
├── app/
│   └── springboot-app/
│
├── terraform/
│
├── scripts/
│
├── monitoring/
│
├── diagrams/
│
├── docs/
│
├── screenshots/
│
├── keys/
│
├── README.md
├── LICENSE
├── .gitignore
└── docker-compose.yml
```

---

# Directory Details

---

## .github/

Contains GitHub-specific configuration.

### workflows/

Stores GitHub Actions workflow files.

Responsibilities:

- Build application
- Build Docker image
- Push image to Amazon ECR
- Deploy to EC2
- Validate deployment

---

## app/

Contains application source code.

Current application:

```
Spring Boot REST API
```

Contents include:

- Controllers
- Services
- Models
- Configuration
- Resources

Responsibilities:

- Business logic
- REST endpoints
- Application configuration

---

## terraform/

Contains Infrastructure as Code (IaC).

Responsibilities:

- Create AWS resources
- Provision networking
- Configure EC2
- Configure IAM
- Security Groups

Typical files include:

```
provider.tf

variables.tf

main.tf

outputs.tf

terraform.tfvars
```

---

## scripts/

Contains automation scripts.

Examples:

- Deployment helpers
- Docker utilities
- Infrastructure utilities

Purpose:

Reduce manual operational work.

---

## monitoring/

Reserved for monitoring resources.

Examples:

- Prometheus configuration
- Grafana dashboards
- Alerting rules

This directory supports future observability enhancements.

---

## diagrams/

Contains project diagrams.

Examples:

- Architecture diagram
- Deployment flow
- Network diagram
- CI/CD workflow

Purpose:

Visual documentation.

---

## docs/

Contains project documentation.

Current documents:

```
architecture.md

ci-cd-workflow.md

deployment.md

troubleshooting.md

aws-services.md

project-structure.md
```

Purpose:

Provide detailed technical documentation.

---

## screenshots/

Contains screenshots captured during implementation.

Suggested organization:

```
screenshots/

├── terraform/

├── ec2/

├── docker/

├── ecr/

├── github-actions/

├── application/

└── architecture/
```

Purpose:

Visual proof of successful implementation.

---

## keys/

Contains SSH key references used during local development.

Important:

Private keys should **never** be committed to Git.

The directory may contain placeholder files or documentation, but sensitive key material must remain outside version control.

---

# Root Files

---

## README.md

Main project documentation.

Includes:

- Project overview
- Features
- Installation
- Architecture
- Screenshots
- Technology stack
- Usage

---

## LICENSE

Defines how the project may be used and shared.

Recommended:

MIT License

---

## .gitignore

Specifies files and directories that Git should ignore.

Examples:

```
target/

.idea/

.vscode/

*.log

.env

terraform.tfstate

terraform.tfstate.backup
```

---

## docker-compose.yml

Defines multi-container deployments when required.

Can be extended in future to support:

- Spring Boot
- Prometheus
- Grafana
- Reverse Proxy
- Databases

---

# Repository Organization Principles

The repository follows several engineering best practices.

## Separation of Concerns

Each directory has a single responsibility.

Examples:

- Infrastructure
- Application
- Documentation
- Automation
- Monitoring

---

## Modularity

Independent components can evolve without affecting unrelated parts of the project.

---

## Scalability

The structure supports future additions such as:

- Kubernetes
- Terraform Modules
- Monitoring Stack
- Application Load Balancer
- Auto Scaling
- Multi-environment deployments

---

## Version Control

All source code, infrastructure definitions, workflows, and documentation are maintained in Git.

Benefits:

- Change tracking
- Collaboration
- Rollback capability
- Audit history

---

# Naming Conventions

The project follows consistent naming practices.

Directories:

```
lowercase-with-hyphens
```

Terraform:

```
snake_case
```

Docker Images:

```
enterprise-aws-devops-platform
```

Git Branches:

```
feature/<feature-name>
```

Examples:

```
feature/vpc-networking

feature/docker-deployment

feature/github-actions-cicd
```

---

# Future Repository Growth

The current structure is designed to accommodate future enhancements, including:

- Kubernetes (Amazon EKS)
- Application Load Balancer (ALB)
- Auto Scaling Groups
- CloudWatch Monitoring
- Prometheus & Grafana
- Multi-environment deployments (Dev, QA, Production)
- Infrastructure modules
- Disaster recovery automation

---

# Summary

The Enterprise AWS DevOps Platform repository is organized to promote clarity, maintainability, and scalability.

By separating infrastructure, application code, automation, documentation, and supporting assets, the project reflects modern DevOps engineering practices and provides a solid foundation for future enhancements.
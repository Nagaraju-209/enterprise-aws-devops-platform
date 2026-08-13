# Application Load Balancer Architecture

## Overview

The Enterprise AWS DevOps Platform uses an AWS Application Load Balancer (ALB) as the public entry point for the Spring Boot application.

The ALB receives HTTP traffic on port 80 and forwards requests to a Target Group containing the EC2 application instance on port 8083.

## Traffic Flow

```text
Internet
   |
   v
Application Load Balancer :80
   |
   v
Target Group :8083
   |
   v
EC2 Instance
   |
   v
Docker Container :8083
   |
   v
Spring Boot Application
```

## Components

### Application Load Balancer

The ALB provides a single public endpoint for the application and distributes HTTP traffic to registered targets.

### Target Group

The Target Group registers the EC2 instance on port 8083.

Health checks use:

```text
Protocol: HTTP
Port: 8083
Path: /health
Expected Response: 200
```

### Security Groups

The ALB Security Group allows HTTP traffic from the internet.

The application Security Group allows port 8083 only from the ALB Security Group.

This prevents direct public application access through port 8083.

## Health Checks

The ALB continuously checks:

```text
/health
```

When the application is unavailable, the target becomes unhealthy and the ALB stops routing traffic to it.

When the application recovers, the target becomes healthy again.

## CI/CD Integration

GitHub Actions deploys the application to EC2 and performs two levels of validation:

1. Application health check on EC2.
2. Application health check through the ALB.

This ensures both the application and production traffic path are operational.

## Security Model

```text
Internet
   |
   | HTTP :80
   v
ALB Security Group
   |
   | TCP :8083
   v
Application Security Group
   |
   v
EC2
```

The EC2 application port is not intended to be directly accessible from the public internet.

## Future Improvements

The architecture can be extended with:

- HTTPS using AWS Certificate Manager
- Auto Scaling Groups
- Multiple EC2 instances
- Blue/Green deployments
- CloudWatch monitoring
- Kubernetes
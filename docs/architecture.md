# Architecture

## Overview

The Enterprise AWS DevOps Platform is a production-inspired AWS architecture for building, containerizing, deploying, exposing, monitoring, and alerting on a Spring Boot application.

The final architecture combines:

- GitHub for source control
- GitHub Actions for CI/CD
- Maven and Java 17 for application build
- Docker for containerization
- Amazon ECR for container image storage
- AWS Systems Manager for EC2 deployment
- Amazon EC2 for application execution
- Application Load Balancer for application access and health checks
- Amazon CloudWatch for monitoring
- Amazon SNS for email alerting
- Terraform for infrastructure provisioning

---

# 1. High-Level Architecture

```text
                              Developer
                                  |
                                  v
                         +----------------+
                         |     GitHub     |
                         +-------+--------+
                                 |
                                 v
                      +-----------------------+
                      |    GitHub Actions     |
                      |-----------------------|
                      | Checkout              |
                      | Java 17               |
                      | Maven Build           |
                      | Docker Build          |
                      | ECR Push              |
                      | SSM Deployment        |
                      | Health Validation     |
                      +-----------+-----------+
                                  |
                                  v
                         +----------------+
                         |   Amazon ECR   |
                         +-------+--------+
                                 |
                                 v
                      +-----------------------+
                      | AWS Systems Manager   |
                      |        (SSM)          |
                      +-----------+-----------+
                                  |
                                  v
                         +----------------+
                         |      EC2       |
                         |----------------|
                         | Docker         |
                         | Spring Boot    |
                         | Port 8083      |
                         +-------+--------+
                                 |
                                 v
                    +---------------------------+
                    | Application Load Balancer |
                    |           Port 80          |
                    +-------------+-------------+
                                  |
                                  v
                             /health
                                  |
                                  v
                           HTTP 200 / Healthy
```

---

# 2. Monitoring Architecture

Monitoring operates alongside the application and load-balancing path.

```text
                         +------------------+
                         |       EC2        |
                         |------------------|
                         | CPU              |
                         | Memory           |
                         | Disk             |
                         | Application      |
                         | Docker           |
                         +---------+--------+
                                   |
                                   |
                         +---------v--------+
                         |    CloudWatch    |
                         |------------------|
                         | Metrics          |
                         | Logs             |
                         | Dashboard       |
                         | Alarms           |
                         +---------+--------+
                                   |
                                   v
                              +---------+
                              |   SNS   |
                              +----+----+
                                   |
                                   v
                              Email Alert
```

ALB metrics are also monitored:

```text
                    Application Load Balancer
                              |
          +-------------------+-------------------+
          |                   |                   |
          v                   v                   v
     5xx Errors        Response Time       Target Health
          |                   |                   |
          +-------------------+-------------------+
                              |
                              v
                         CloudWatch
```

---

# 3. AWS Network Architecture

Terraform provisions the AWS networking layer.

```text
                              Internet
                                  |
                                  v
                         +----------------+
                         | Internet GW    |
                         +-------+--------+
                                 |
                                 v
                    +---------------------------+
                    |            VPC            |
                    |                           |
                    |     Public Subnets        |
                    |                           |
                    |   +-------------------+   |
                    |   |        ALB        |   |
                    |   +---------+---------+   |
                    |             |             |
                    |             v             |
                    |        EC2 Instance       |
                    |                           |
                    |     Private Subnet        |
                    |             |             |
                    |             v             |
                    |        NAT Gateway        |
                    |                           |
                    +---------------------------+
```

The infrastructure includes:

- VPC
- Public subnet
- Private subnet
- Internet Gateway
- NAT Gateway
- Elastic IP
- Public route table
- Private route table
- Route associations
- Security groups

The exact subnet placement and route configuration should remain defined by the Terraform configuration rather than being manually recreated.

---

# 4. Component Responsibilities

## 4.1 GitHub

GitHub is the source-control system for the project.

Responsibilities:

- Store application source code.
- Store Terraform configuration.
- Store GitHub Actions workflow definitions.
- Maintain feature branches.
- Maintain the final `main` branch.
- Preserve project history.

Important branches include:

```text
main
feature/github-actions-cicd
feature/application-load-balancer
feature/cloudwatch-monitoring
```

The CloudWatch monitoring branch is intentionally retained as development history after the work was merged into `main`.

---

## 4.2 GitHub Actions

GitHub Actions provides the CI/CD automation layer.

Responsibilities:

- Checkout source code.
- Configure Java 17.
- Build/package the application.
- Build Docker images.
- Authenticate with Amazon ECR.
- Push Docker images.
- Initiate SSM deployment.
- Validate deployment health.

The final deployment flow is:

```text
GitHub
   |
   v
GitHub Actions
   |
   +-- Maven
   |
   +-- Docker
   |
   +-- ECR
   |
   +-- SSM
```

---

## 4.3 Terraform

Terraform is the Infrastructure as Code layer.

Terraform manages the AWS infrastructure instead of requiring manual creation.

The infrastructure covers the project's:

- Network
- Compute
- IAM
- Security groups
- ECR-related resources
- Application Load Balancer
- Target group
- CloudWatch
- SNS

Terraform lifecycle:

```text
Terraform Configuration
        |
        v
terraform plan
        |
        v
terraform apply
        |
        v
AWS Infrastructure
```

After project validation:

```text
terraform destroy
        |
        v
AWS Infrastructure Removed
```

---

# 5. VPC Layer

The VPC provides network isolation for the application infrastructure.

Conceptually:

```text
+--------------------------------------------------+
|                    AWS VPC                       |
|                                                  |
|   +------------------+    +------------------+   |
|   | Public Subnet    |    | Private Subnet   |   |
|   |                  |    |                  |   |
|   | ALB              |    | Application      |   |
|   |                  |    | infrastructure   |   |
|   +--------+---------+    +---------+--------+   |
|            |                        |            |
|            +------------+-----------+            |
|                         |                        |
|                    NAT Gateway                  |
|                                                  |
+--------------------------------------------------+
```

The VPC is connected to the Internet through an Internet Gateway.

The NAT Gateway provides outbound connectivity for resources that require it without making the private network directly internet-facing.

---

# 6. Security Group Layer

Security groups control network access to the infrastructure.

The final application path is:

```text
Internet
   |
   v
ALB
   |
   v
EC2 :8083
```

The application port is:

```text
8083
```

Temporary SSH access was used during troubleshooting and restricted to a single source address before being removed.

The final security posture does not depend on permanent inbound SSH access for CI/CD.

---

# 7. EC2 Layer

Amazon EC2 provides the application compute environment.

```text
+----------------------------------+
|              EC2                 |
|                                  |
|  Amazon Linux                    |
|                                  |
|  +----------------------------+  |
|  |           Docker           |  |
|  |                            |  |
|  |  +----------------------+  |  |
|  |  |    enterprise-app    |  |  |
|  |  |----------------------|  |  |
|  |  | Spring Boot          |  |  |
|  |  | Port: 8083           |  |  |
|  |  +----------------------+  |  |
|  +----------------------------+  |
|                                  |
|  SSM Agent                       |
+----------------------------------+
```

The EC2 instance provides:

- Docker runtime
- Spring Boot application runtime
- SSM Agent
- CloudWatch monitoring capabilities

---

# 8. Docker Layer

Docker packages the Spring Boot application into a portable container.

```text
Spring Boot Application
          |
          v
        Maven
          |
          v
        JAR
          |
          v
      Dockerfile
          |
          v
    Docker Image
          |
          v
       Amazon ECR
```

The running container is:

```text
enterprise-app
```

The application listens on:

```text
8083
```

---

# 9. Amazon ECR Layer

Amazon Elastic Container Registry stores the Docker images used for deployment.

```text
GitHub Actions
      |
      v
Docker Build
      |
      v
Docker Image
      |
      v
Amazon ECR
      |
      v
EC2 Deployment
```

Image tags provide deployment traceability.

A commit SHA can identify the exact source revision associated with an image.

Example:

```text
<account>.dkr.ecr.<region>.amazonaws.com/enterprise-aws-devops-platform:<commit-sha>
```

---

# 10. AWS Systems Manager Layer

AWS Systems Manager provides the final deployment mechanism.

```text
                  GitHub Actions
                        |
                        v
                  AWS SSM Command
                        |
                        v
                       EC2
                        |
              +---------+---------+
              |                   |
              v                   v
          ECR Login           Container
              |                   |
              v                   v
         Pull Image          Start App
```

SSM eliminates the need for the normal CI/CD pipeline to connect directly to EC2 through SSH.

The EC2 instance requires:

- SSM Agent
- Appropriate IAM instance profile
- Network connectivity to AWS Systems Manager endpoints

---

# 11. Application Layer

The Spring Boot application runs inside Docker.

```text
             Docker
                |
                v
       +----------------+
       | enterprise-app |
       +-------+--------+
               |
               v
        Spring Boot
           :8083
```

Application health:

```text
GET /health
```

Expected response:

```text
HTTP 200
```

---

# 12. Application Load Balancer Layer

The ALB provides the public entry point.

```text
                    Internet
                       |
                       v
              +----------------+
              |      ALB       |
              |      :80       |
              +-------+--------+
                      |
                      v
                Target Group
                      |
                      v
                  EC2 :8083
                      |
                      v
                 Docker App
```

The target group health check uses:

```text
/health
```

The ALB therefore validates application availability independently of the deployment command itself.

---

# 13. ALB Health Model

The health model is:

```text
Application Running
       |
       v
/health returns 200
       |
       v
ALB Health Check
       |
       v
Target = healthy
```

Failure:

```text
Application Failure
       |
       v
/health fails
       |
       v
ALB Target = unhealthy
```

Recovery:

```text
Application Restored
       |
       v
/health = 200
       |
       v
ALB Target = healthy
```

---

# 14. CloudWatch Layer

CloudWatch provides observability.

The monitoring architecture covers:

```text
EC2
 |
 +-- CPU
 +-- Memory
 +-- Disk
 |
 v
CloudWatch
```

Application/container logs can also be collected and retained through CloudWatch Logs.

ALB metrics are monitored through CloudWatch as well.

---

# 15. CloudWatch Dashboard

The CloudWatch dashboard provides an operational view of the platform.

The dashboard can combine:

```text
EC2 Metrics
    +
ALB Metrics
    +
Application/Operational Metrics
```

This provides a centralized view of infrastructure and application health.

---

# 16. CloudWatch Alarms

The final implementation includes alarms for important conditions.

```text
+---------------------------------------------+
|             CloudWatch Alarms               |
+---------------------------------------------+
| EC2 High CPU                                |
| ALB 5xx Errors                              |
| ALB High Response Time                      |
| ALB No Healthy Targets                      |
| ALB Unhealthy Targets                       |
+----------------------+----------------------+
                       |
                       v
                      SNS
```

The final alarm set includes:

```text
enterprise-devops-ec2-high-cpu
enterprise-devops-alb-5xx-errors
enterprise-devops-alb-high-response-time
enterprise-devops-alb-no-healthy-targets
enterprise-devops-alb-unhealthy-targets
```

---

# 17. SNS Alerting Layer

SNS provides email notifications for CloudWatch alarms.

```text
CloudWatch
    |
    v
Alarm
    |
    v
SNS Topic
    |
    v
Email Subscription
    |
    v
Email Notification
```

The email subscription was successfully confirmed during project validation.

---

# 18. Failure Detection Architecture

The platform was tested with an intentional application failure.

```text
                Application
                     |
                     X
              Container stopped
                     |
                     v
                 ALB Target
                     |
                     v
                  Unhealthy
                     |
                     v
               CloudWatch
                     |
                     v
                  ALARM
                     |
                     v
                   SNS
                     |
                     v
                  Email
```

This validates the complete operational chain.

---

# 19. Recovery Architecture

After the application was restored:

```text
Application Restarted
        |
        v
/health -> HTTP 200
        |
        v
ALB Target -> healthy
        |
        v
CloudWatch Alarm -> OK
```

The project therefore validates both failure detection and recovery.

---

# 20. End-to-End Data Flow

The final application delivery path is:

```text
                         Source Code
                              |
                              v
                           GitHub
                              |
                              v
                       GitHub Actions
                              |
                    +---------+---------+
                    |                   |
                    v                   v
                 Maven              Docker
                    |                   |
                    +---------+---------+
                              |
                              v
                         Amazon ECR
                              |
                              v
                            SSM
                              |
                              v
                            EC2
                              |
                              v
                           Docker
                              |
                              v
                       Spring Boot
                           :8083
                              |
                              v
                            ALB
                              |
                              v
                         /health
                              |
                              v
                           Healthy
```

---

# 21. End-to-End Monitoring Flow

```text
                    EC2 / Application
                            |
                            v
                           ALB
                            |
              +-------------+-------------+
              |                           |
              v                           v
         Application                 ALB Metrics
            Logs                         |
              |                           |
              +-------------+-------------+
                            |
                            v
                       CloudWatch
                            |
             +--------------+--------------+
             |              |              |
             v              v              v
            Logs         Dashboard       Alarms
                                           |
                                           v
                                          SNS
                                           |
                                           v
                                         Email
```

---

# 22. Deployment and Operations Separation

The architecture separates deployment from monitoring.

### Deployment path

```text
GitHub
  |
  v
GitHub Actions
  |
  v
ECR
  |
  v
SSM
  |
  v
EC2
```

### Traffic path

```text
Internet
   |
   v
ALB
   |
   v
EC2
   |
   v
Application
```

### Monitoring path

```text
EC2 / ALB
    |
    v
CloudWatch
    |
    v
SNS
    |
    v
Email
```

This separation makes the architecture easier to reason about and troubleshoot.

---

# 23. Security Architecture

The final security model is based on controlled AWS access.

```text
GitHub Actions
      |
      | AWS API
      v
AWS Services
      |
      v
SSM
      |
      v
EC2
```

Normal deployment does not require:

```text
GitHub Actions -> SSH :22 -> EC2
```

Instead:

```text
GitHub Actions -> SSM -> EC2
```

Temporary SSH access was used only during troubleshooting and was removed after recovery.

---

# 24. IAM Responsibilities

IAM is used to provide the required AWS permissions.

The architecture separates:

- CI/CD AWS permissions
- EC2 instance permissions
- SSM permissions
- ECR image access
- Monitoring-related access

The exact IAM policy definitions remain controlled by Terraform.

When modifying the architecture, IAM policies should follow least-privilege principles.

---

# 25. Infrastructure Lifecycle

The complete infrastructure lifecycle is:

```text
Terraform Configuration
          |
          v
     terraform init
          |
          v
     terraform plan
          |
          v
     terraform apply
          |
          v
   AWS Infrastructure
          |
          v
      Validation
          |
          v
    Project Complete
          |
          v
    terraform destroy
          |
          v
 AWS Infrastructure Removed
```

The final project environment was intentionally destroyed after validation.

---

# 26. Final Project State

The final state is:

```text
AWS Infrastructure       -> Destroyed
Terraform State           -> Empty
GitHub Repository         -> Preserved
main Branch               -> Preserved
feature/cloudwatch-monitoring
                          -> Preserved
Project Documentation    -> Preserved
```

The infrastructure can be recreated from the Terraform configuration when required.

---

# 27. Architecture Decisions

## Terraform

Chosen to make AWS infrastructure reproducible and version-controlled.

## Docker

Chosen to package the application consistently across environments.

## Amazon ECR

Chosen to provide a private AWS-native container registry.

## AWS Systems Manager

Chosen for EC2 deployment without making SSH the normal CI/CD access mechanism.

## Application Load Balancer

Chosen to provide a stable application endpoint and target health checking.

## CloudWatch

Chosen for AWS-native metrics, logs, dashboards, and alarms.

## SNS

Chosen to provide email notifications from CloudWatch alarms.

## GitHub Actions

Chosen to automate the application delivery lifecycle directly from the Git repository.

---

# 28. Failure and Troubleshooting Architecture

A major troubleshooting incident involved an SSM command remaining in:

```text
InProgress
```

after an EC2 reboot.

The architecture helped isolate the issue by validating each layer independently:

```text
EC2
 |
 +-- Instance running?        YES
 |
 +-- SSM Agent running?       YES
 |
 +-- IAM credentials?         YES
 |
 +-- SSM endpoint reachable?  YES
 |
 +-- SSM command state?       STALE / FAILED
 |
 +-- Application health?      Separate validation
 |
 +-- ALB health?              Separate validation
```

This layered approach prevented incorrectly destroying and rebuilding healthy infrastructure to solve an application-level or command-state issue.

---

# 29. Validation Architecture

A deployment is validated at several layers.

```text
Layer 1
GitHub Actions
      |
      v
Workflow = SUCCESS

Layer 2
EC2
      |
      v
Container = RUNNING

Layer 3
Application
      |
      v
/health = HTTP 200

Layer 4
ALB
      |
      v
Target = HEALTHY

Layer 5
CloudWatch
      |
      v
Alarms = OK
```

This provides stronger validation than checking only whether the deployment command exited successfully.

---

# 30. Future Architecture Improvements

The completed architecture can be extended with:

### High Availability

```text
ALB
 |
 +-- EC2 / Instance 1
 |
 +-- EC2 / Instance 2
```

using an Auto Scaling Group.

### Safer Deployments

Introduce:

- Rolling deployments
- Blue/green deployments
- Automated rollback

### HTTPS

Add:

```text
Route 53
   |
   v
ACM Certificate
   |
   v
HTTPS ALB
```

### Secrets

Introduce:

- AWS Secrets Manager
- Systems Manager Parameter Store

### CI/CD Authentication

Use GitHub Actions OIDC with AWS IAM to reduce reliance on long-lived credentials.

### Advanced Observability

Introduce:

- Prometheus
- Grafana
- OpenTelemetry
- Distributed tracing
- Application-level metrics

---

# 31. Final Architecture Summary

The completed architecture can be summarized as:

```text
                           GITHUB
                             |
                             v
                      GITHUB ACTIONS
                             |
                 +-----------+-----------+
                 |                       |
                 v                       v
              MAVEN                   DOCKER
                                         |
                                         v
                                      ECR
                                         |
                                         v
                                       SSM
                                         |
                                         v
                                       EC2
                                         |
                                         v
                                      DOCKER
                                         |
                                         v
                                  SPRING BOOT
                                     :8083
                                         |
                                         v
                                       ALB
                                         |
                                         v
                                  /health -> 200
```

Monitoring:

```text
                    EC2 + ALB
                         |
                         v
                    CLOUDWATCH
                  /      |      \
               LOGS   METRICS   ALARMS
                                  |
                                  v
                                 SNS
                                  |
                                  v
                                EMAIL
```

The final design demonstrates a complete DevOps lifecycle:

```text
SOURCE
  |
  v
BUILD
  |
  v
CONTAINERIZE
  |
  v
PUBLISH
  |
  v
DEPLOY
  |
  v
LOAD BALANCE
  |
  v
MONITOR
  |
  v
ALERT
  |
  v
RECOVER
```

The project was successfully validated and the temporary AWS infrastructure was destroyed after completion to avoid unnecessary ongoing cloud costs.

---

## Visual Evidence

Screenshots are embedded next to the relevant implementation and validation sections above. The complete screenshot library is available in the repository [`screenshots/`](../screenshots/).

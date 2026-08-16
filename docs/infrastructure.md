# Infrastructure

## Overview

The Enterprise AWS DevOps Platform uses **Terraform** to provision and manage the AWS infrastructure required by the application.

The infrastructure was designed as a production-inspired environment containing:

- Amazon VPC
- Public and private subnets
- Internet Gateway
- NAT Gateway
- Route tables and route associations
- Security groups
- Amazon EC2
- IAM roles and policies
- Amazon ECR integration
- Application Load Balancer
- ALB target group and health checks
- Amazon CloudWatch monitoring
- CloudWatch alarms
- Amazon SNS
- AWS Systems Manager integration

The final AWS environment was successfully validated and then intentionally destroyed after project completion.

---

# 1. Infrastructure Architecture

```text
                              AWS Account
                                  |
                                  v
                         +----------------+
                         |      VPC       |
                         |                |
                         |  Public Layer  |
                         |                |
                         |  +----------+  |
Internet ---> IGW ------>|  |   ALB    |  |
                         |  +----+-----+  |
                         |       |        |
                         |       v        |
                         |     EC2        |
                         |                |
                         | Private Layer  |
                         |       |        |
                         |       v        |
                         |   NAT Gateway  |
                         +----------------+
```

Operational services:

```text
                         AWS Infrastructure
                                |
            +-------------------+-------------------+
            |                   |                   |
            v                   v                   v
           ECR                 SSM             CloudWatch
            |                   |                   |
            |                   v                   v
            |                  EC2                SNS
            |                                       |
            +---------------------------------------+
                                                    |
                                                    v
                                                  Email
```

---

# 2. Terraform as Infrastructure as Code

Terraform is the primary Infrastructure as Code tool for the project.

Instead of manually creating AWS resources through the AWS Console, the infrastructure is described in Terraform configuration files and applied through the Terraform CLI.

The general lifecycle is:

```text
Terraform Configuration
        |
        v
terraform init
        |
        v
terraform validate
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

When the temporary environment is no longer required:

```text
terraform plan -destroy
        |
        v
terraform destroy
        |
        v
AWS Infrastructure Removed
```

---

# 3. Terraform Workflow

## Initialize

From the Terraform directory:

```bash
terraform init
```

This initializes the working directory and downloads the required provider plugins.

---

## Validate

```bash
terraform validate
```

This verifies that the Terraform configuration is syntactically valid and internally consistent.

---

## Review Changes

```bash
terraform plan
```

The plan should always be reviewed before applying infrastructure changes.

The project used this workflow throughout development to identify resources that would be:

```text
+ create
~ change
- destroy
```

---

## Apply

```bash
terraform apply
```

Terraform provisions the resources defined by the configuration.

The final infrastructure provisioning completed successfully with the expected resources created.

---

# 4. VPC

The VPC provides the isolated network environment for the AWS application.

The final infrastructure included:

```text
VPC
 |
 +-- Public Subnet
 |
 +-- Private Subnet
 |
 +-- Internet Gateway
 |
 +-- NAT Gateway
 |
 +-- Route Tables
 |
 +-- Route Associations
 |
 +-- Security Groups
```

The final provisioned VPC ID during validation was:

```text
vpc-0b8853de0db4f66ad
```

This identifier belongs to the temporary project environment and no longer exists after the final Terraform destroy.

---

# 5. Public Subnet

The public subnet is associated with routing that provides access through the Internet Gateway.

The final provisioned public subnet ID during validation was:

```text
subnet-0aabd1cb6653a6f7d
```

The public layer is used for internet-facing infrastructure such as the Application Load Balancer.

---

# 6. Private Subnet

The private subnet provides an internal network layer for resources that do not need to be directly exposed to the Internet.

The final provisioned private subnet ID during validation was:

```text
subnet-056d73cc7e15608f4
```

Outbound access for private resources is provided through the NAT Gateway where required.

---

# 7. Internet Gateway

The Internet Gateway provides connectivity between the VPC public routing layer and the Internet.

The final provisioned Internet Gateway ID was:

```text
igw-06d7e1e6e9fc25fa2
```

Traffic flow:

```text
Internet
   |
   v
Internet Gateway
   |
   v
VPC Public Route
   |
   v
Public Resources
```

---

# 8. NAT Gateway

The NAT Gateway provides outbound Internet connectivity for resources located in private network space without requiring direct inbound Internet access.

The final provisioned NAT Gateway ID was:

```text
nat-076ee57a707b79798
```

Conceptually:

```text
Private Subnet
      |
      v
Private Route Table
      |
      v
NAT Gateway
      |
      v
Internet Gateway
      |
      v
Internet
```

---

# 9. Route Tables

The networking layer uses separate routing behavior for public and private resources.

## Public routing

```text
Public Subnet
     |
     v
Public Route Table
     |
     v
Internet Gateway
```

## Private routing

```text
Private Subnet
     |
     v
Private Route Table
     |
     v
NAT Gateway
```

This separation supports a controlled network architecture.

---

# 10. Security Groups

Security groups provide stateful network access control.

The application runs on:

```text
8083
```

The Application Load Balancer provides the public application entry point.

The intended traffic flow is:

```text
Internet
   |
   v
ALB
   |
   v
EC2 :8083
```

The normal deployment path does not require inbound SSH.

---

# 11. Temporary SSH Access During Troubleshooting

During troubleshooting, temporary SSH access was required to investigate the EC2/SSM issue.

The temporary access was restricted to a single source address using `/32` notation.

Example:

```text
49.15.207.58/32
```

After troubleshooting was completed, the temporary SSH rule was revoked.

The final security configuration therefore did not retain the temporary troubleshooting access.

This is an important operational practice:

```text
Temporary Access
       |
       v
Troubleshoot
       |
       v
Remove Access
```

---

# 12. EC2

Amazon EC2 provides the compute environment for the application.

The final provisioned instance ID during validation was:

```text
i-0b4f4c5039cc5dc82
```

The private IP during validation was:

```text
10.0.1.252
```

The public IP during validation was:

```text
13.232.110.8
```

These values belonged to the temporary environment and are no longer active after the final Terraform destroy.

---

# 13. EC2 Application Runtime

The application runs inside Docker on the EC2 instance.

```text
EC2
 |
 +-- Docker
      |
      +-- enterprise-app
             |
             +-- Spring Boot
             +-- Port 8083
```

The container is configured to expose:

```text
8083
```

The application health endpoint is:

```text
/health
```

---

# 14. IAM

IAM provides AWS permissions to the resources and automation components.

The project uses IAM for:

- EC2 instance permissions
- Systems Manager access
- ECR image access
- CloudWatch-related access
- CI/CD AWS operations

The principle is to provide the permissions required for each component rather than relying on broad administrative access.

---

# 15. EC2 Instance Profile

The EC2 instance uses an IAM instance profile so that the instance can obtain AWS credentials without storing static AWS credentials on the server.

The SSM Agent successfully retrieved instance profile credentials during project validation.

The operational flow is:

```text
EC2
 |
 v
Instance Metadata
 |
 v
IAM Instance Profile
 |
 v
Temporary AWS Credentials
 |
 +-- SSM
 +-- ECR
 +-- Other permitted AWS APIs
```

---

# 16. AWS Systems Manager

AWS Systems Manager provides the final deployment mechanism.

```text
GitHub Actions
      |
      v
SSM SendCommand
      |
      v
EC2
      |
      v
Docker Deployment
```

This removes the need for the CI/CD pipeline to depend on inbound SSH access.

The EC2 instance must have:

- SSM Agent
- IAM instance profile
- Network connectivity to Systems Manager endpoints

---

# 17. Amazon ECR

Amazon Elastic Container Registry stores the Docker image.

The infrastructure and deployment workflow use ECR as the container registry:

```text
GitHub Actions
      |
      v
Docker Build
      |
      v
Amazon ECR
      |
      v
EC2 / SSM
      |
      v
Docker Pull
```

The image is versioned using deployment-related tags, including the Git commit SHA.

Example:

```text
<account>.dkr.ecr.<region>.amazonaws.com/enterprise-aws-devops-platform:<commit-sha>
```

---

# 18. Application Load Balancer

The Application Load Balancer provides the public entry point for the application.

```text
Internet
   |
   v
Application Load Balancer
   |
   v
Target Group
   |
   v
EC2 :8083
```

The ALB also provides the target health-check mechanism.

---

# 19. Target Group

The target group points the ALB to the EC2 application port.

The application port is:

```text
8083
```

The health check uses:

```text
/health
```

The expected target state is:

```text
healthy
```

The final project validation confirmed that the target became healthy after successful deployment.

---

# 20. ALB Health Check

The health-check flow is:

```text
ALB
 |
 v
EC2 :8083
 |
 v
GET /health
 |
 v
HTTP 200
 |
 v
Target = healthy
```

When the application was intentionally stopped:

```text
ALB
 |
 v
EC2 :8083
 |
 X
Application unavailable
 |
 v
Target = unhealthy
```

This health behavior is also used by the monitoring layer.

---

# 21. CloudWatch Logs

CloudWatch Logs provide centralized log storage for the monitoring implementation.

The project includes CloudWatch log configuration through Terraform.

The monitoring design supports collecting operational logs instead of relying exclusively on SSH access for diagnosis.

Conceptually:

```text
Application / EC2
       |
       v
CloudWatch Logs
       |
       v
Operational Investigation
```

Log retention is configured as part of the Terraform monitoring resources.

---

# 22. CloudWatch Metrics

The monitoring implementation covers infrastructure and load-balancer metrics.

The monitored areas include:

```text
EC2
 |
 +-- CPU
 +-- Memory
 +-- Disk

ALB
 |
 +-- 5xx Errors
 +-- Response Time
 +-- Healthy Targets
 +-- Unhealthy Targets
```

These metrics are used by the CloudWatch alarms.

---

# 23. CloudWatch Dashboard

A CloudWatch dashboard provides a centralized operational view.

The dashboard combines relevant metrics for:

- EC2
- ALB
- Application health
- Infrastructure health

The dashboard is provisioned through Terraform rather than manually configured.

---

# 24. CloudWatch Alarms

The final infrastructure includes the following alarms:

```text
enterprise-devops-ec2-high-cpu
enterprise-devops-alb-5xx-errors
enterprise-devops-alb-high-response-time
enterprise-devops-alb-no-healthy-targets
enterprise-devops-alb-unhealthy-targets
```

The alarm architecture is:

```text
Metric
  |
  v
CloudWatch Alarm
  |
  +-- OK
  |
  +-- ALARM
          |
          v
         SNS
```

During final validation, the alarms returned to the healthy `OK` state after application recovery.

---

# 25. Amazon SNS

Amazon SNS provides the notification layer for CloudWatch alarms.

```text
CloudWatch Alarm
       |
       v
SNS Topic
       |
       v
Email Subscription
```

The email subscription was confirmed during project validation.

This provides a human notification path when monitored conditions cross their configured thresholds.

---

# 26. Infrastructure Dependency Flow

The major Terraform-managed dependencies can be represented as:

```text
VPC
 |
 +-- Subnets
 |     |
 |     +-- Route Tables
 |     |
 |     +-- Internet Gateway
 |     |
 |     +-- NAT Gateway
 |
 +-- Security Groups
 |
 +-- EC2
 |     |
 |     +-- IAM Instance Profile
 |     +-- SSM
 |     +-- Docker
 |
 +-- ALB
 |     |
 |     +-- Target Group
 |           |
 |           +-- EC2 :8083
 |
 +-- CloudWatch
 |
 +-- SNS
```

The exact Terraform dependency graph is determined by the resource references in the configuration.

---

# 27. Infrastructure Provisioning Sequence

A practical provisioning sequence is:

```text
Terraform Init
      |
      v
Terraform Validate
      |
      v
Terraform Plan
      |
      v
Network Resources
      |
      v
IAM / Security Resources
      |
      v
EC2
      |
      v
ECR Integration
      |
      v
ALB + Target Group
      |
      v
CloudWatch
      |
      v
SNS
      |
      v
Infrastructure Ready
```

Terraform resolves the actual dependency ordering automatically.

---

# 28. Infrastructure Validation

After provisioning, infrastructure should be validated at multiple levels.

## Terraform

```bash
terraform plan
```

Expected state after successful application:

```text
No changes.
Your infrastructure matches the configuration.
```


> **Evidence — Terraform-created resources**
>
> ![Terraform-created resources](../screenshots/vpc-networking/terraform-apply-resources.png)

## EC2

Verify:

```bash
aws ec2 describe-instances
```


> **Evidence — EC2 instance**
>
> ![EC2 instance](../screenshots/security-compute/ec2-instance.png)

> **Evidence — IAM role**
>
> ![IAM role](../screenshots/security-compute/iam-role.png)

## SSM

Verify the instance is available to Systems Manager.

## ALB

Verify target health:

```bash
aws elbv2 describe-target-health \
  --target-group-arn "<target-group-arn>"
```

Expected:

```text
healthy
```

## Application

Verify:

```text
/health
```

Expected:

```text
HTTP 200
```

## CloudWatch

Verify:

- Dashboard
- Alarm states
- Logs

## SNS

Verify:

- Topic
- Subscription
- Confirmation

---

# 29. Terraform Drift Validation

Terraform was also used to verify that the actual AWS infrastructure matched the declared configuration.

The expected clean state is:

```text
No changes.
Your infrastructure matches the configuration.
```

This means Terraform did not identify unexpected differences between the configuration and the deployed infrastructure at that point in the project lifecycle.

---

# 30. Infrastructure Destruction

Because the project environment was temporary, the infrastructure was intentionally destroyed after all validation was complete.

First review:

```bash
terraform plan -destroy
```

Then destroy:

```bash
terraform destroy
```

Terraform removes the resources under its management.

The expected final result is:

```text
Destroy complete!
```

---

# 31. Final Terraform State

After destruction, the Terraform state was verified.

```bash
terraform state list
```

The final state showed no remaining managed resources.

Conceptually:

```text
Terraform State
      |
      v
   Empty
```

This confirms that the temporary AWS environment was not left running.

---

# 32. Cost-Control Strategy

The AWS infrastructure was created for a project and learning environment rather than a permanent production workload.

To avoid unnecessary ongoing charges:

```text
Build
  |
  v
Deploy
  |
  v
Validate
  |
  v
Document
  |
  v
Destroy
```

The final environment was destroyed after documentation and validation.

This is especially important for cost-bearing resources such as:

- NAT Gateway
- EC2
- Load Balancer
- Elastic IP-related resources
- CloudWatch usage

---

# 33. Infrastructure Troubleshooting

The project included a real SSM deployment issue.

An SSM command became stuck in:

```text
InProgress
```

After an EC2 reboot, the SSM Agent resumed the old command state.

The agent logs showed:

```text
Found in-progress document
```

followed by:

```text
process ... not found
```

and:

```text
ipc messaging received timeout signal
```

However, the SSM Agent itself was running and successfully connected to:

```text
ssmmessages.ap-south-1.amazonaws.com
```

This helped establish that the problem was not simply an EC2 availability or basic SSM network connectivity problem.

The stale command state was cleared, SSM was tested again, and the final deployment succeeded.

---

# 34. Infrastructure and Application Separation

A key design principle is separating infrastructure responsibilities from application responsibilities.

### Infrastructure

Terraform manages:

```text
VPC
Subnets
Routes
NAT
IGW
Security Groups
EC2
IAM
ALB
Target Group
CloudWatch
SNS
```

### Application

The application repository manages:

```text
Spring Boot
Maven
Dockerfile
Application Configuration
```

### CI/CD

GitHub Actions manages:

```text
Build
Package
Docker Build
ECR Push
SSM Deployment
Validation
```

This separation makes each layer independently understandable and maintainable.

---

# 35. Security Considerations

The infrastructure follows several practical security principles.

## No normal CI/CD SSH dependency

The final deployment path is:

```text
GitHub Actions
      |
      v
SSM
      |
      v
EC2
```

## Temporary troubleshooting access

SSH was temporarily enabled only for troubleshooting and restricted to a `/32` source.

It was removed afterward.

## IAM

AWS permissions are provided through IAM rather than embedding AWS credentials directly into the EC2 host.

## Network isolation

The VPC separates public and private network behavior.

## Application exposure

The application is intended to be reached through the ALB rather than directly exposing the EC2 instance as the primary application endpoint.

---

# 36. Recreating the Environment

The infrastructure can be recreated from the repository.

General process:

```bash
git clone https://github.com/Nagaraju-209/enterprise-aws-devops-platform.git

cd enterprise-aws-devops-platform/terraform

terraform init

terraform validate

terraform plan

terraform apply
```

After infrastructure provisioning:

```text
AWS Infrastructure
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
       |
       v
ALB
```

The exact current variable values, secrets, credentials, and AWS account-specific configuration should be taken from the repository's Terraform configuration and deployment workflow rather than hard-coded into documentation.

---

# 37. Destroying a Recreated Environment

When the environment is no longer required:

```bash
cd terraform

terraform plan -destroy

terraform destroy
```

Then verify:

```bash
terraform state list
```

Also verify in AWS that no unintended resources remain.

---

# 38. Final Infrastructure Outputs

During the final successful provisioning, Terraform produced the following important outputs:

```text
alb_dns_name
ec2_instance_id
ec2_private_ip
ec2_public_dns
ec2_public_ip
internet_gateway_id
nat_gateway_id
private_subnet_id
public_subnet_id
vpc_id
```

Example values from the temporary environment included:

```text
ALB:
enterprise-alb-348083509.ap-south-1.elb.amazonaws.com

EC2:
i-0b4f4c5039cc5dc82

Private IP:
10.0.1.252

Public IP:
13.232.110.8

VPC:
vpc-0b8853de0db4f66ad
```

These values are documented as historical validation outputs only. They should not be treated as currently active infrastructure because the final environment was destroyed.

---

# 39. Infrastructure Validation Summary

The infrastructure implementation successfully demonstrated:

```text
Terraform
   |
   v
VPC
   |
   +-- Public Networking
   +-- Private Networking
   +-- NAT
   +-- Internet Gateway
   |
   v
EC2
   |
   +-- IAM
   +-- SSM
   +-- Docker
   |
   v
ALB
   |
   v
Target Group
   |
   v
Spring Boot
   |
   v
CloudWatch
   |
   v
SNS
```

The infrastructure was provisioned successfully, validated through application and monitoring tests, and destroyed after completion.

---

# 40. Final Infrastructure State

The project ended with:

```text
Terraform Configuration     -> Preserved
Terraform State              -> Empty
AWS Infrastructure           -> Destroyed
GitHub Repository            -> Preserved
Git History                  -> Preserved
Documentation                -> Preserved
```

The environment is therefore reproducible without leaving the temporary AWS resources running.

---

# 41. Infrastructure Design Summary

The final infrastructure demonstrates the following DevOps principles:

```text
Infrastructure as Code
        |
        v
Reproducibility
        |
        v
Automated Deployment
        |
        v
Controlled Network Access
        |
        v
Load Balancing
        |
        v
Observability
        |
        v
Alerting
        |
        v
Failure Detection
        |
        v
Recovery
        |
        v
Controlled Teardown
```

The project therefore covers the complete infrastructure lifecycle:

```text
PROVISION
    |
    v
CONFIGURE
    |
    v
DEPLOY
    |
    v
VALIDATE
    |
    v
MONITOR
    |
    v
TROUBLESHOOT
    |
    v
RECOVER
    |
    v
DESTROY
```

---

## Visual Evidence

Screenshots are embedded next to the relevant implementation and validation sections above. The complete screenshot library is available in the repository [`screenshots/`](../screenshots/).

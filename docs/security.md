# Security

## Overview

The Enterprise AWS DevOps Platform uses a layered security approach across source control, CI/CD, IAM, networking, EC2, container deployment, and monitoring.

The final security design focuses on:

- Controlled AWS access
- IAM-based authentication and authorization
- Network segmentation
- Security groups
- Reduced dependency on inbound SSH
- AWS Systems Manager for deployment
- Private container image storage in Amazon ECR
- Terraform-managed infrastructure
- Temporary troubleshooting access with explicit cleanup
- CloudWatch monitoring and alerting
- Version-controlled security configuration

The project was designed as a production-inspired DevOps platform rather than a permanent production environment.

---

# 1. Security Architecture

```text
                         GitHub
                            |
                            v
                     GitHub Actions
                            |
                            v
                     AWS API Access
                            |
                            v
                          SSM
                            |
                            v
                           EC2
                            |
                    +-------+-------+
                    |               |
                    v               v
                 Docker            IAM
                    |
                    v
                   ECR
```

Network security:

```text
Internet
    |
    v
   ALB
    |
    v
Security Group
    |
    v
EC2 :8083
```

Monitoring and alerting:

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

---

# 2. Security Goals

The security implementation is designed to:

- Limit network exposure.
- Avoid unnecessary public access to the application host.
- Use IAM instead of static credentials where possible.
- Use AWS Systems Manager instead of making SSH the normal CI/CD deployment mechanism.
- Keep container images in Amazon ECR.
- Manage infrastructure and security configuration through Terraform.
- Restrict temporary troubleshooting access.
- Remove temporary security rules after troubleshooting.
- Monitor infrastructure and application health.
- Preserve security-related configuration in Git.

---

# 3. Security Layers

The project can be viewed as multiple security layers.

```text
Layer 1
Source Control
      |
      v
GitHub

Layer 2
CI/CD
      |
      v
GitHub Actions

Layer 3
AWS Authorization
      |
      v
IAM

Layer 4
Network
      |
      v
VPC + Subnets + Security Groups

Layer 5
Compute
      |
      v
EC2

Layer 6
Container
      |
      v
Docker + ECR

Layer 7
Deployment Access
      |
      v
AWS Systems Manager

Layer 8
Monitoring
      |
      v
CloudWatch + SNS
```

---

# 4. Infrastructure as Code Security

Terraform is used to define the AWS infrastructure.

Security-related infrastructure is therefore version controlled.

Examples include:

```text
VPC
Subnets
Route Tables
Security Groups
IAM
EC2
ALB
CloudWatch
SNS
SSM-related resources
```

The lifecycle is:

```text
Terraform Configuration
        |
        v
Code Review
        |
        v
terraform plan
        |
        v
terraform apply
```

This reduces the risk of undocumented manual infrastructure changes.

---

# 5. IAM

AWS Identity and Access Management provides authentication and authorization for AWS resources.

The project uses IAM for:

- EC2 permissions
- Systems Manager access
- ECR access
- CloudWatch-related access
- CI/CD AWS operations

The intended model is:

```text
Identity
   |
   v
IAM
   |
   v
Permission
   |
   v
AWS Resource
```

IAM policies should provide only the permissions required by each component.

---

# 6. EC2 Instance Profile

The EC2 instance uses an IAM instance profile.

This allows the EC2 host to obtain temporary AWS credentials through its assigned role instead of storing long-lived AWS access keys on the server.

The flow is:

```text
EC2
 |
 v
Instance Profile
 |
 v
IAM Role
 |
 v
Temporary Credentials
 |
 +-- SSM
 +-- ECR
 +-- Other permitted APIs
```

During validation, the SSM Agent successfully obtained credentials from the EC2 instance profile.

---

# 7. Least-Privilege Principle

The architecture follows a least-privilege approach.

The intended model is:

```text
Component
    |
    v
Required Permission
    |
    v
Required Resource
```

Rather than:

```text
Component
    |
    v
Administrator Access
    |
    v
Everything
```

When expanding the project, IAM permissions should be narrowed further where practical.

---

# 8. GitHub Security

GitHub is the source-control system for the project.

Security-sensitive configuration should not be committed directly into the repository.

Do not commit:

```text
AWS Access Keys
AWS Secret Keys
Private Keys
Passwords
Database Passwords
API Tokens
SSM Credentials
SNS Credentials
```

Instead, use:

- GitHub Actions secrets
- GitHub Actions variables
- AWS IAM
- OIDC where appropriate
- AWS Secrets Manager or Parameter Store for application secrets

---

# 9. GitHub Actions Security

GitHub Actions performs the CI/CD operations.

The pipeline accesses AWS services to:

```text
Build
 |
v
Authenticate
 |
v
Push to ECR
 |
v
Deploy through SSM
```

The workflow should use the minimum AWS permissions required for those operations.

The deployment design intentionally avoids using a permanent SSH private key as the normal CI/CD deployment credential.

---

# 10. AWS Systems Manager Security

AWS Systems Manager is the final EC2 deployment mechanism.

The deployment path is:

```text
GitHub Actions
      |
      v
AWS Systems Manager
      |
      v
EC2
```

This is preferable to exposing SSH as the normal deployment channel.

SSM requires:

- SSM Agent on EC2
- Appropriate EC2 IAM instance profile
- Network connectivity to AWS Systems Manager endpoints

---

# 11. Why SSM Instead of SSH?

The project originally required SSH during troubleshooting, but the final CI/CD deployment mechanism uses SSM.

### SSH model

```text
GitHub Actions
      |
      v
Internet
      |
      v
EC2 :22
```

This requires an inbound SSH security-group rule and SSH credential management.


> **Evidence — Temporary SSH troubleshooting access**
>
> ![Temporary SSH troubleshooting access](../screenshots/security-compute/ssh-connection.png)

### SSM model

```text
GitHub Actions
      |
      v
AWS Systems Manager
      |
      v
EC2
```

This removes the normal requirement for inbound SSH access from the CI/CD path.

---

# 12. SSM Agent

The EC2 instance runs the Amazon SSM Agent.

The service is expected to be:

```text
active (running)
```

The SSM Agent provides the communication mechanism between EC2 and Systems Manager.

Operationally:

```text
SSM Agent
    |
    v
AWS Systems Manager
```

The project validated the SSM Agent status and logs during troubleshooting.

---

# 13. SSM Network Security

The SSM Agent communicates with AWS Systems Manager endpoints.

During troubleshooting, the EC2 instance successfully established a connection to:

```text
ssmmessages.ap-south-1.amazonaws.com
```

This validated the basic SSM message-channel connectivity.

The architecture therefore does not require exposing the SSM management interface through an inbound application port.

---

# 14. VPC Security

The application infrastructure runs inside an Amazon VPC.

The VPC provides network isolation.

Conceptually:

```text
+--------------------------------------------+
|                    VPC                     |
|                                            |
|   Public Network       Private Network     |
|                                            |
|   +-----------+       +---------------+    |
|   |    ALB    | ----> |      EC2      |    |
|   +-----------+       +---------------+    |
|                                            |
+--------------------------------------------+
```

Public and private routing is handled separately.

---

# 15. Public and Private Subnets

The network architecture separates public and private subnet behavior.

```text
Internet
   |
   v
Internet Gateway
   |
   v
Public Subnet
   |
   v
ALB
```

Private resources can use:

```text
Private Subnet
   |
   v
NAT Gateway
   |
   v
Internet Gateway
```

This separation reduces direct exposure of internal resources.

---

# 16. Internet Gateway

The Internet Gateway provides internet connectivity for the VPC public routing layer.

```text
Internet
   |
   v
Internet Gateway
   |
   v
Public Route Table
   |
   v
Public Subnet
```

The Internet Gateway itself does not replace security controls.

Traffic remains subject to route tables and security groups.

---

# 17. NAT Gateway

The NAT Gateway provides outbound connectivity for private network resources.

```text
Private Subnet
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

The purpose is to allow outbound communication without requiring private resources to have direct inbound internet exposure.

---

# 18. Security Groups

Security groups provide the primary network access-control layer for the application resources.

The intended application flow is:

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

The security-group rules should allow only the traffic required by the architecture.

---

# 19. ALB Security Boundary

The Application Load Balancer acts as the public application entry point.

```text
Internet
   |
   v
ALB
   |
   v
Target Group
   |
   v
EC2
```

This architecture avoids using the EC2 public IP as the primary application endpoint.

The ALB also provides health checking for the application.

---

# 20. Application Port

The Spring Boot application listens on:

```text
8083
```

The application health endpoint is:

```text
/health
```

The intended access path is:

```text
Client
  |
  v
ALB
  |
  v
EC2 :8083
  |
  v
Spring Boot
```

---

# 21. Temporary SSH Access

During troubleshooting, SSH access was temporarily required to inspect the EC2 instance.

The temporary access was restricted to a single source address using `/32`.

Example:

```text
49.15.207.58/32
```

This is significantly narrower than:

```text
0.0.0.0/0
```

The temporary rule was removed after troubleshooting.

The operational principle is:

```text
Temporary Access
      |
      v
Troubleshoot
      |
      v
Verify
      |
      v
Revoke Access
```

---

# 22. Security Group Rule Cleanup

A security-group rule ID must be an AWS-generated rule identifier.

An IP address such as:

```text
49.15.207.58
```

or:

```text
49.15.207.58/32
```

is not itself a security-group rule ID.

This distinction caused an error during troubleshooting when an IP address was supplied to:

```bash
--security-group-rule-id
```

The correct approach is to identify the actual AWS security-group rule ID or revoke the rule using the appropriate rule parameters.

The important security outcome was that the temporary SSH access was removed.

---

# 23. No Permanent SSH Dependency

The final deployment architecture does not depend on inbound SSH.

```text
CI/CD
 |
 v
SSM
 |
 v
EC2
```

SSH remains an administrative troubleshooting mechanism rather than the standard deployment mechanism.

This reduces:

- SSH credential management
- Permanent inbound SSH exposure
- CI/CD dependence on a private key
- Attack surface associated with exposed port 22

---

# 24. Container Security

The application runs inside Docker.

```text
EC2
 |
 v
Docker
 |
 v
enterprise-app
 |
 v
Spring Boot
```

The container image is stored in Amazon ECR.

The CI/CD pipeline pulls the intended image version during deployment.

Using a registry-based deployment model provides a controlled path:

```text
Source
  |
  v
Docker Image
  |
  v
ECR
  |
  v
EC2
```

---

# 25. Amazon ECR Security

Amazon ECR provides private storage for the application's container image.

The security model is:

```text
Authorized CI/CD
       |
       v
ECR Push

Authorized EC2
       |
       v
ECR Pull
```

ECR access should be controlled through IAM permissions.

---

# 26. Image Traceability

The Docker image uses versioned tags.

The project uses Git commit SHA-based tagging for deployment traceability.

Example:

```text
enterprise-aws-devops-platform:<commit-sha>
```

This creates a relationship between:

```text
Git Commit
    |
    v
Docker Image
    |
    v
ECR
    |
    v
EC2 Deployment
```

This is useful when investigating which application revision is running.

---

# 27. Secrets Management

Sensitive values should not be stored directly in:

```text
Terraform files
Application source code
Dockerfiles
GitHub repository
README files
```

Potential secure mechanisms include:

```text
GitHub Actions Secrets
        |
        v
CI/CD

AWS Secrets Manager
        |
        v
Application Secrets

SSM Parameter Store
        |
        v
Configuration
```

The exact secret-management implementation is outside the validated final scope unless explicitly defined in the Terraform/application configuration.

---

# 28. Terraform State Security

Terraform state can contain sensitive infrastructure information.

The state file should therefore be treated as sensitive.

Important practices include:

- Do not commit local state files unnecessarily.
- Restrict access to Terraform state.
- Protect backend storage if a remote backend is used.
- Avoid exposing sensitive outputs.
- Use appropriate AWS IAM permissions.

The final project used Terraform state to manage the temporary infrastructure and verified that the state contained no remaining managed resources after destruction.

---

# 29. Monitoring Security

CloudWatch and SNS provide the monitoring and notification security layer.

```text
EC2 / ALB
    |
    v
CloudWatch
    |
    v
Alarm
    |
    v
SNS
    |
    v
Email
```

Monitoring allows operational teams to detect security-relevant infrastructure conditions such as:

- Unexpected resource utilization
- Application failures
- ALB errors
- Target health degradation

The monitoring implementation is not a replacement for a full security monitoring platform, but it provides operational visibility.

---

# 30. Security and Failure Detection

The intentional application failure test demonstrated that the security and monitoring architecture could detect an application availability problem.

The sequence was:

```text
Container Stopped
       |
       v
ALB Health Check Fails
       |
       v
Target Unhealthy
       |
       v
CloudWatch Alarm
       |
       v
SNS
       |
       v
Email
```

After recovery:

```text
Container Running
       |
       v
/health = 200
       |
       v
ALB Target Healthy
       |
       v
CloudWatch = OK
```

---

# 31. SSM Incident Security Analysis

During the project, an SSM deployment command became stuck in:

```text
InProgress
```

The EC2 instance was rebooted and the SSM Agent resumed processing the old command state.

The agent logs showed:

```text
Found in-progress document
```

and later:

```text
process ... not found
```

followed by:

```text
ipc messaging received timeout signal
```

At the same time, the SSM Agent:

- Was running.
- Obtained EC2 instance-profile credentials.
- Established the SSM control channel.
- Connected to the `ssmmessages` endpoint.

This demonstrated an important security/operations distinction:

```text
EC2 Identity
       !=
SSM Command State
       !=
Application Health
```

The issue was resolved without changing the fundamental security architecture.

---

# 32. Security Validation

The security-related implementation was validated through:

```text
[✓] IAM-based EC2 permissions
[✓] SSM Agent running
[✓] SSM instance identity
[✓] SSM control-channel connectivity
[✓] VPC networking
[✓] Security groups
[✓] ALB-based application access
[✓] Temporary SSH restriction
[✓] Temporary SSH cleanup
[✓] ECR image deployment
[✓] CloudWatch monitoring
[✓] SNS alerting
[✓] Terraform-managed infrastructure
```

---

# 33. Security Testing Checklist

When recreating the environment, verify:

```text
[ ] EC2 has the expected IAM instance profile
[ ] SSM Agent is running
[ ] SSM reports the instance as managed
[ ] Required SSM endpoints are reachable
[ ] Security groups allow only required traffic
[ ] Application is exposed through the ALB
[ ] EC2 does not require permanent public SSH access
[ ] ECR repository is private
[ ] CI/CD has required AWS permissions
[ ] No secrets are committed to Git
[ ] CloudWatch alarms exist
[ ] SNS subscription is confirmed
```

---

# 34. Security Troubleshooting Checklist

## If SSM fails

Check:

```bash
sudo systemctl status amazon-ssm-agent --no-pager -l
```

Then:

```bash
sudo journalctl -u amazon-ssm-agent --no-pager -n 100
```

And:

```bash
sudo tail -100 /var/log/amazon/ssm/amazon-ssm-agent.log
```

Verify:

- Agent status
- IAM instance profile
- AWS credentials
- Network connectivity
- SSM endpoint access
- Command state

---

## If ALB is unhealthy

Check:

```text
ALB
 |
 v
Target Group
 |
 v
EC2 :8083
 |
 v
/health
```

Then inspect:

```bash
docker ps
```

and:

```bash
docker logs enterprise-app
```

---

## If ECR pull fails

Check:

- IAM permissions
- ECR repository
- Image tag
- AWS region
- ECR authentication
- EC2 network access

---

# 35. Security Incident Response Model

For an application/infrastructure issue:

```text
Detect
  |
  v
Investigate
  |
  v
Contain
  |
  v
Recover
  |
  v
Validate
  |
  v
Document
```

For example:

```text
ALB Alarm
   |
   v
Check Target
   |
   v
Check EC2
   |
   v
Check Container
   |
   v
Check Logs
   |
   v
Fix
   |
   v
Verify ALB Health
```

---

# 36. Security and Infrastructure Teardown

The AWS environment was temporary.

After the project was completely validated:

```text
terraform destroy
```

was used to remove the infrastructure.

The final Terraform state contained no remaining managed resources.

This is also a security practice because unused resources should not remain active indefinitely.

The teardown removed the temporary:

```text
EC2
ALB
NAT Gateway
VPC
Security Groups
CloudWatch Resources
SNS Resources
Other Terraform-managed AWS Resources
```

---

# 37. Security and Cost Control

Security and cost control overlap in temporary environments.

Leaving unused resources running can:

- Increase cloud costs.
- Increase attack surface.
- Leave unnecessary endpoints active.
- Leave temporary access rules in place.

The project therefore followed:

```text
Create
  |
  v
Test
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

---

# 38. Security Design Improvements

The final project provides a strong foundation, but several improvements could make it closer to a production-grade implementation.

## GitHub Actions OIDC

Use GitHub Actions OIDC instead of long-lived AWS access keys.

```text
GitHub Actions
      |
      v
OIDC
      |
      v
AWS IAM Role
      |
      v
AWS APIs
```

Benefits:

- No long-lived AWS access key required.
- Short-lived credentials.
- Repository/branch-based trust policies.

---

## HTTPS

The ALB can be upgraded to HTTPS:

```text
Client
  |
  v
HTTPS
  |
  v
ALB
  |
  v
EC2
```

AWS Certificate Manager can provide the TLS certificate.

---

## AWS WAF

AWS WAF can be placed in front of the ALB:

```text
Internet
   |
   v
AWS WAF
   |
   v
ALB
   |
   v
EC2
```

This can provide additional web-application protection.

---

## Secrets Manager

Sensitive application configuration can be moved to:

```text
AWS Secrets Manager
```

instead of storing secrets in environment files or repository configuration.

---

## ECR Image Scanning

Enable ECR image scanning to detect vulnerabilities in container images.

A stronger pipeline can become:

```text
Docker Build
    |
    v
Security Scan
    |
    v
ECR
    |
    v
Deployment
```

---

# 39. Recommended Production Security Architecture

A future production version could use:

```text
                         Internet
                            |
                            v
                           WAF
                            |
                            v
                          ALB
                            |
                            v
                    Private EC2 / ASG
                            |
                            v
                         Docker
                            |
                            v
                           App
```

Deployment:

```text
GitHub
   |
   v
GitHub Actions
   |
   v
OIDC
   |
   v
AWS IAM Role
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

Secrets:

```text
Secrets Manager
      |
      v
Application
```

Monitoring:

```text
EC2 / ALB / Application
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

---

# 40. Final Security Summary

The completed platform demonstrates several important DevOps security principles:

```text
                 SECURITY
                    |
        +-----------+-----------+
        |           |           |
        v           v           v
       IAM        NETWORK      CI/CD
        |           |           |
        v           v           v
   Least Priv.   VPC/SG       SSM
        |           |           |
        +-----------+-----------+
                    |
                    v
                  EC2
                    |
                    v
                 Docker
                    |
                    v
                   ECR
                    |
                    v
               Monitoring
                    |
                    v
                CloudWatch
                    |
                    v
                   SNS
```

The project specifically demonstrated:

- IAM-based AWS resource access.
- EC2 instance-profile credentials.
- VPC network isolation.
- Security-group-controlled traffic.
- ALB-based application exposure.
- Reduced reliance on inbound SSH.
- SSM-based EC2 deployment.
- Private ECR image storage.
- Temporary troubleshooting access with `/32` restriction.
- Removal of temporary security access.
- Terraform-managed security configuration.
- CloudWatch monitoring and SNS alerting.
- Controlled infrastructure teardown.

---

# 41. Final Security State

After project completion:

```text
AWS Infrastructure      -> Destroyed
Temporary SSH Rule      -> Removed
Terraform State         -> Empty
GitHub Repository       -> Preserved
Terraform Configuration -> Preserved
Security Documentation  -> Preserved
```

The security configuration can therefore be recreated from the version-controlled Terraform configuration when the environment is needed again.

---

# 42. Security Principles Demonstrated

The project demonstrates the following principles:

```text
Least Privilege
       |
       v
Network Segmentation
       |
       v
Controlled Access
       |
       v
No Permanent SSH Dependency
       |
       v
Private Container Registry
       |
       v
Infrastructure as Code
       |
       v
Monitoring
       |
       v
Alerting
       |
       v
Temporary Access Cleanup
       |
       v
Controlled Teardown
```

These principles form the security foundation of the Enterprise AWS DevOps Platform.

---

## Visual Evidence

Screenshots are embedded next to the relevant implementation and validation sections above. The complete screenshot library is available in the repository [`screenshots/`](../screenshots/).

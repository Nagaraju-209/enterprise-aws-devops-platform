# Application Load Balancer

## Overview

The Enterprise AWS DevOps Platform uses an **Application Load Balancer (ALB)** as the public entry point for the Spring Boot application running inside Docker on an EC2 instance.

The ALB provides:

- Public application access
- Traffic routing to EC2
- Target-group management
- Application health checks
- Detection of unhealthy application targets
- Integration with CloudWatch monitoring
- A stable DNS endpoint in front of the EC2 application

The final traffic flow is:

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
EC2 Instance
    |
    v
Docker Container
    |
    v
Spring Boot :8083
```

---

# 1. ALB Architecture

```text
                         Internet
                            |
                            v
                +-----------------------+
                | Application Load      |
                | Balancer              |
                +-----------+-----------+
                            |
                            v
                +-----------------------+
                | Target Group          |
                | Port: 8083            |
                | Health: /health       |
                +-----------+-----------+
                            |
                            v
                +-----------------------+
                | EC2 Instance          |
                | 10.0.1.252             |
                +-----------+-----------+
                            |
                            v
                +-----------------------+
                | Docker                |
                | enterprise-app        |
                | Port: 8083            |
                +-----------+-----------+
                            |
                            v
                       Spring Boot
```

---

# 2. Why an Application Load Balancer?

The ALB separates the public application endpoint from the EC2 instance.

Without an ALB:

```text
Client
  |
  v
EC2 Public IP
  |
  v
Application
```

With the ALB:

```text
Client
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

This provides a cleaner application architecture and creates a dedicated layer for:

- Routing
- Health checks
- Target management
- Availability monitoring
- Future scaling

---

# 3. ALB Components

The implementation consists of:

```text
Application Load Balancer
        |
        +-- Listener
        |
        +-- Target Group
        |
        +-- Target
              |
              +-- EC2 :8083
```

The ALB works together with:

```text
VPC
Subnets
Security Groups
EC2
Docker
Spring Boot
CloudWatch
```

---

# 4. VPC Integration

The ALB is deployed inside the project VPC.

Conceptually:

```text
+--------------------------------------------------+
| VPC                                              |
|                                                  |
|  +------------------+                            |
|  | Public Subnet    |                            |
|  |                  |                            |
|  |      ALB         |                            |
|  +--------+---------+                            |
|           |                                      |
|           v                                      |
|  +------------------+                            |
|  | Application      |                            |
|  | Target           |                            |
|  |                  |                            |
|  | EC2 :8083        |                            |
|  +------------------+                            |
|                                                  |
+--------------------------------------------------+
```

The ALB uses the configured VPC subnets and security groups defined by Terraform.

---

# 5. Public Application Entry Point

The ALB is the public-facing application entry point.

The final application access pattern is:

```text
Internet
   |
   v
ALB DNS
   |
   v
ALB Listener
   |
   v
Target Group
   |
   v
EC2 :8083
```

The temporary EC2 public address should not be treated as the primary application endpoint.

---

# 6. ALB DNS

Terraform produced an ALB DNS output during infrastructure validation.

A historical value was:

```text
enterprise-alb-348083509.ap-south-1.elb.amazonaws.com
```

This value belonged to the temporary AWS environment and is no longer active because the infrastructure was destroyed after project completion.

When the infrastructure is recreated, AWS will generate a new ALB DNS name.

---

# 7. Target Group

The ALB forwards application traffic to a target group.

The target group contains the EC2 instance.

Conceptually:

```text
ALB
 |
 v
Target Group
 |
 v
i-0b4f4c5039cc5dc82
 |
 v
Port 8083
```

The target group is responsible for maintaining target registration and health state.

---

# 8. Target Port

The application target listens on:

```text
8083
```

The Docker container exposes:

```text
8083
```

The complete port mapping is:

```text
ALB
 |
 | TCP :8083
 v
EC2
 |
 | :8083
 v
Docker
 |
 | :8083
 v
Spring Boot
```

---

# 9. Health Check

The ALB target group performs an application health check.

The configured health endpoint is:

```text
/health
```

The expected result is:

```text
HTTP 200
```

The health flow is:

```text
ALB
 |
 v
GET /health
 |
 v
EC2 :8083
 |
 v
Spring Boot
 |
 v
HTTP 200
 |
 v
Target = healthy
```

---

# 10. Why `/health`?

The health endpoint provides a simple application-level availability check.

The ALB is therefore not only checking whether the EC2 network port is reachable.

It also verifies that the application responds through the configured health path.

```text
Network
   +
Application
   |
   v
/health
```

This provides more useful health information than checking only whether the TCP port is open.

---

# 11. Healthy Target

When the application is running correctly:

```text
Port   State
8083   healthy
```

The final project validation produced:

```text
+------+-----------+-----------------------+
| Port |   State   |        Target         |
+------+-----------+-----------------------+
| 8083 |  healthy  |  i-0b4f4c5039cc5dc82  |
+------+-----------+-----------------------+
```

This confirmed that the ALB could successfully reach the application target.

---

# 12. Unhealthy Target

When the application container is unavailable:

```text
Docker Container
       |
       X
Stopped
       |
       v
/health unavailable
       |
       v
ALB health check fails
       |
       v
Target = unhealthy
```

This condition was intentionally tested during the project.

---

# 13. Intentional Failure Test

The application container was intentionally stopped using SSM for monitoring validation.

The SSM command output was:

```text
enterprise-app
Application container intentionally stopped for monitoring test
```

After the container was stopped:

```text
Application
     |
     v
Unavailable
     |
     v
ALB Health Check
     |
     v
Unhealthy
```

This demonstrated that the ALB correctly detected application availability changes.

---

# 14. No Healthy Targets

The project includes the CloudWatch alarm:

```text
enterprise-devops-alb-no-healthy-targets
```

When the application was intentionally stopped and no target remained healthy, this alarm entered:

```text
ALARM
```

The flow was:

```text
Container stopped
       |
       v
Target unhealthy
       |
       v
Healthy targets = 0
       |
       v
CloudWatch
       |
       v
ALARM
```

---

# 15. Unhealthy Targets Alarm

The project also includes:

```text
enterprise-devops-alb-unhealthy-targets
```

This alarm detects unhealthy target conditions.

The intentional failure test caused the relevant target-health alarms to enter `ALARM`.

This validated the relationship between:

```text
Application Failure
       |
       v
ALB Health Check
       |
       v
Target Health
       |
       v
CloudWatch Alarm
```

---

# 16. Recovery

After the application was restored:

```text
Docker Container
       |
       v
Running
       |
       v
Spring Boot
       |
       v
/health = HTTP 200
       |
       v
ALB Target = healthy
```

The CloudWatch alarms subsequently returned to:

```text
OK
```

This validated both failure detection and recovery.

---

# 17. ALB and CI/CD

The ALB is part of the deployment validation process.

The deployment pipeline follows:

```text
GitHub
   |
   v
GitHub Actions
   |
   v
Build
   |
   v
Docker
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
Docker Container
   |
   v
ALB Health Check
   |
   v
Healthy
```

Therefore, deployment success is verified beyond simply checking that the SSM command completed.

---

# 18. ALB and Docker

The ALB routes traffic to the EC2 instance on port `8083`.

Docker maps the host port to the application container:

```text
EC2 :8083
     |
     v
Docker :8083
     |
     v
Spring Boot
```

The container used by the project is:

```text
enterprise-app
```

---

# 19. Container Validation

On EC2, the application container can be checked with:

```bash
docker ps
```

Expected container:

```text
enterprise-app
```

Expected port mapping:

```text
0.0.0.0:8083->8083/tcp
```

Example from the project:

```text
691f7cd2fb73
enterprise-app
0.0.0.0:8083->8083/tcp
```

The exact container ID changes after each container recreation.

---

# 20. ALB Security Group

The ALB uses an AWS security group to control inbound and outbound traffic.

The intended architecture is:

```text
Internet
   |
   v
ALB Security Group
   |
   v
ALB
```

Only required application traffic should be permitted.

The ALB security group is separate from the EC2 security-group controls.

---

# 21. EC2 Security Group

The EC2 security group controls access to the application host.

The intended flow is:

```text
ALB
 |
 v
EC2 Security Group
 |
 v
EC2 :8083
```

This provides a security boundary between the public ALB and the backend instance.

---

# 22. ALB to EC2 Traffic

The application traffic path is:

```text
Client
  |
  | HTTP
  v
ALB
  |
  | HTTP :8083
  v
EC2
  |
  | Docker :8083
  v
Spring Boot
```

The security groups must permit the required traffic between the ALB and EC2.

---

# 23. Health Check Traffic

Health-check traffic follows the same backend path:

```text
ALB
 |
 | GET /health
 v
EC2 :8083
 |
 v
Docker
 |
 v
Spring Boot
```

If the application returns an acceptable health response, the target remains healthy.

---

# 24. ALB Monitoring

The ALB is integrated with CloudWatch.

The monitored areas include:

```text
ALB
 |
 +-- 5xx Errors
 |
 +-- Response Time
 |
 +-- Target Health
```

The corresponding project alarms are:

```text
enterprise-devops-alb-5xx-errors
enterprise-devops-alb-high-response-time
enterprise-devops-alb-no-healthy-targets
enterprise-devops-alb-unhealthy-targets
```

---

# 25. ALB 5xx Monitoring

The project monitors ALB 5xx errors.

Alarm:

```text
enterprise-devops-alb-5xx-errors
```

The conceptual flow is:

```text
Application Request
       |
       v
ALB
       |
       v
5xx Response
       |
       v
CloudWatch
       |
       v
Alarm
```

A sustained increase in server-side errors can indicate an application or backend problem.

---

# 26. ALB Response-Time Monitoring

The project includes:

```text
enterprise-devops-alb-high-response-time
```

This monitors elevated response times.

The flow is:

```text
Client Request
      |
      v
ALB
      |
      v
Backend
      |
      v
Response
      |
      v
Response Time Metric
      |
      v
CloudWatch Alarm
```

High response time can indicate application performance or resource issues.

---

# 27. ALB and CloudWatch Dashboard

The ALB metrics are included in the CloudWatch monitoring architecture.

The dashboard provides a centralized view of:

```text
EC2 Metrics
ALB Metrics
Target Health
Application Availability
```

The dashboard is managed using Terraform.

---

# 28. ALB and SNS

CloudWatch alarms can trigger the SNS notification path.

```text
ALB
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

The project successfully confirmed the SNS email subscription.

During the failure test, the alarm state changes validated the monitoring and notification architecture.

---

# 29. ALB Health Check Failure Lifecycle

A typical failure looks like:

```text
Application Container
       |
       X
Stopped
       |
       v
ALB /health Check
       |
       X
Fails
       |
       v
Target = unhealthy
       |
       v
No healthy targets
       |
       v
CloudWatch = ALARM
       |
       v
SNS Notification
```

Recovery:

```text
Application Container
       |
       v
Started
       |
       v
/health = 200
       |
       v
Target = healthy
       |
       v
CloudWatch = OK
```

---

# 30. ALB Validation Using AWS CLI

Target health can be inspected with:

```bash
aws elbv2 describe-target-health \
  --target-group-arn "<target-group-arn>" \
  --query 'TargetHealthDescriptions[].{Target:Target.Id,Port:Target.Port,State:TargetHealth.State,Reason:TargetHealth.Reason}' \
  --output table
```

Expected healthy state:

```text
Port   State
8083   healthy
```

The target state is one of the most important deployment validation signals.

---

# 31. ALB Validation Checklist

After deployment:

```text
[ ] ALB exists
[ ] ALB listener exists
[ ] Target group exists
[ ] EC2 is registered
[ ] Target port is 8083
[ ] Health path is /health
[ ] Target is healthy
[ ] ALB DNS resolves
[ ] Application responds
[ ] CloudWatch ALB alarms are OK
```

---

# 32. Troubleshooting: Target Unhealthy

If the target is unhealthy, investigate in this order:

```text
1. Check target health
       |
       v
2. Check EC2 status
       |
       v
3. Check Docker container
       |
       v
4. Check application logs
       |
       v
5. Check /health
       |
       v
6. Check port 8083
       |
       v
7. Check security groups
```

Useful command:

```bash
docker ps
```

Then:

```bash
docker logs enterprise-app
```

---

# 33. Troubleshooting: Container Not Running

If:

```bash
docker ps
```

does not show:

```text
enterprise-app
```

inspect:

```bash
docker ps -a
```

Then inspect logs:

```bash
docker logs enterprise-app
```

If the container was removed, redeploy through the CI/CD pipeline rather than manually rebuilding the environment unless troubleshooting requires it.

---

# 34. Troubleshooting: Health Endpoint Failure

If the container is running but the target is unhealthy:

```text
Container = Running
        |
        v
Application?
        |
        v
/health?
```

Check application logs:

```bash
docker logs enterprise-app
```

Verify that the application is listening on:

```text
8083
```

and that:

```text
/health
```

returns the expected health response.

---

# 35. Troubleshooting: Security Group

If the application works locally on EC2 but the ALB reports the target as unhealthy, check:

```text
ALB Security Group
       |
       v
EC2 Security Group
       |
       v
Port 8083
```

The EC2 security group must allow the required traffic from the ALB path.

Do not solve an ALB health-check problem by unnecessarily opening the application port to:

```text
0.0.0.0/0
```

Prefer the narrowest appropriate source.

---

# 36. Troubleshooting: 5xx Errors

If:

```text
enterprise-devops-alb-5xx-errors
```

enters `ALARM`, check:

```text
ALB Metrics
     |
     v
Target Health
     |
     v
Container
     |
     v
Application Logs
```

Potential causes include:

- Application errors
- Backend failures
- Dependency failures
- Incorrect application configuration
- Resource pressure

---

# 37. Troubleshooting: High Response Time

If:

```text
enterprise-devops-alb-high-response-time
```

enters `ALARM`, inspect:

```text
ALB Response Time
       |
       v
EC2 CPU
       |
       v
EC2 Memory
       |
       v
Application Logs
```

The goal is to determine whether latency is caused by the application, infrastructure, or workload.

---

# 38. ALB and SSM Deployment

SSM deploys the application to EC2, while the ALB validates application availability.

These systems have different responsibilities:

```text
SSM
 |
 +-- Deployment

ALB
 |
 +-- Application Availability
```

Therefore:

```text
SSM = Success
```

does not automatically mean:

```text
ALB = Healthy
```

Both must be checked.

---

# 39. Deployment Validation Chain

The complete validation chain is:

```text
GitHub Actions
      |
      v
SSM = Success
      |
      v
Docker = Running
      |
      v
Spring Boot = Started
      |
      v
/health = 200
      |
      v
ALB Target = healthy
      |
      v
CloudWatch = OK
```

This is the preferred definition of a successful deployment.

---

# 40. ALB Failure Testing

The project intentionally stopped the application container.

The resulting behavior demonstrated:

```text
Application Down
       |
       v
ALB Health Check Failure
       |
       v
Target Unhealthy
       |
       v
CloudWatch Alarm
       |
       v
SNS Alerting
```

This was not a simulated alarm-state change; it was based on an actual application availability failure.

---

# 41. ALB Recovery Testing

After the application was restarted/redeployed:

```text
Application Up
       |
       v
Health Check Pass
       |
       v
Target Healthy
       |
       v
CloudWatch Alarm -> OK
```

This demonstrated that the target-health monitoring recovered correctly.

---

# 42. Infrastructure as Code

The ALB configuration is managed by Terraform.

This includes the relevant:

```text
ALB
Target Group
Listeners
Security Groups
Networking
CloudWatch Alarms
```

The exact Terraform resources and values in the repository are the source of truth.

This provides:

- Reproducibility
- Version control
- Change tracking
- Consistent recreation

---

# 43. ALB Terraform Lifecycle

The infrastructure lifecycle is:

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
ALB Created
        |
        v
Target Registered
        |
        v
Health Check
        |
        v
Traffic Served
```

Teardown:

```text
terraform destroy
        |
        v
ALB Removed
```

---

# 44. Terraform Validation

Before applying ALB changes:

```bash
terraform fmt
```

Then:

```bash
terraform validate
```

Then:

```bash
terraform plan
```

Apply only after reviewing the plan:

```bash
terraform apply
```

The final project was destroyed using Terraform after all validation and documentation were completed.

---

# 45. Historical Infrastructure State

During the project, Terraform successfully reached:

```text
No changes. Your infrastructure matches the configuration.
```

The ALB target was also validated as:

```text
healthy
```

After the project was completed:

```text
terraform destroy
```

was executed.

The final Terraform state contained no managed infrastructure.

Therefore, the historical ALB values documented here are for project reference and are not currently active.

---

# 46. ALB Security Model

The ALB provides a public entry point while EC2 remains behind the application routing layer.

The intended security flow is:

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
Docker
   |
   v
Spring Boot
```

The EC2 application port should not be made broadly public just because the ALB needs access to it.

---

# 47. HTTPS Production Improvement

The validated project used the ALB as the application entry point.

For a production deployment, HTTPS should be added:

```text
Client
   |
   | HTTPS :443
   v
ALB
   |
   | HTTP/HTTPS
   v
EC2
```

AWS Certificate Manager can be used to manage the TLS certificate.

The production design could therefore become:

```text
Internet
   |
   v
HTTPS
   |
   v
ALB
   |
   v
Target Group
   |
   v
Private EC2
```

---

# 48. High Availability Improvement

The project used a single EC2 application target.

A production-scale design could use multiple targets:

```text
             ALB
              |
       +------+------+
       |             |
       v             v
     EC2-1         EC2-2
       |             |
       v             v
     App-1         App-2
```

The ALB can distribute traffic across healthy targets.

This also improves availability when one target fails.

---

# 49. Auto Scaling Improvement

A future architecture could use an Auto Scaling Group:

```text
                    ALB
                     |
                     v
              Target Group
                     |
          +----------+----------+
          |                     |
          v                     v
       EC2-1                 EC2-2
```

Auto Scaling can maintain the desired number of application instances.

The current project provides the foundation through the ALB and target-group design.

---

# 50. WAF Improvement

A production environment could place AWS WAF in front of the ALB:

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
Target Group
   |
   v
EC2
```

WAF can provide an additional layer of web-application protection.

---

# 51. Final ALB Architecture

The complete validated architecture is:

```text
                         Internet
                            |
                            v
              +---------------------------+
              | Application Load Balancer |
              +-------------+-------------+
                            |
                            v
                  +-------------------+
                  | Target Group      |
                  | Port 8083         |
                  | /health           |
                  +---------+---------+
                            |
                            v
                  +-------------------+
                  | EC2 Instance      |
                  +---------+---------+
                            |
                            v
                  +-------------------+
                  | Docker            |
                  | enterprise-app    |
                  +---------+---------+
                            |
                            v
                  +-------------------+
                  | Spring Boot       |
                  | :8083             |
                  +-------------------+
```

Monitoring:

```text
ALB
 |
 +-- 5xx Errors
 +-- Response Time
 +-- Target Health
        |
        v
   CloudWatch
        |
        v
      Alarms
        |
        v
       SNS
        |
        v
      Email
```

---

# 52. Final ALB Validation

The project validated:

```text
[✓] ALB created through Terraform
[✓] ALB DNS generated
[✓] Target group created
[✓] EC2 registered as target
[✓] Target port 8083
[✓] Health path /health
[✓] Target healthy during normal operation
[✓] Target unhealthy during intentional failure
[✓] No-healthy-target alarm triggered
[✓] Unhealthy-target alarm triggered
[✓] Application recovery
[✓] Target returned to healthy
[✓] CloudWatch alarms returned to OK
[✓] ALB integrated with CI/CD validation
```

---

# 53. Final Project State

At the end of the project:

```text
ALB Configuration       -> Preserved in Terraform
Target Group            -> Preserved in Terraform
Health Check            -> Preserved in Terraform
Security Configuration  -> Preserved in Terraform
CloudWatch Integration  -> Preserved in Terraform
AWS ALB                 -> Destroyed
Terraform State         -> Empty
Documentation           -> Preserved
```

The ALB can be recreated when the Terraform infrastructure is deployed again.

---

# 54. Summary

The Application Load Balancer provides the application-facing traffic and health layer of the Enterprise AWS DevOps Platform.

The validated flow is:

```text
Client
  |
  v
ALB
  |
  v
Target Group
  |
  v
EC2 :8083
  |
  v
Docker
  |
  v
Spring Boot
  |
  v
/health
```

The ALB also integrates directly with monitoring:

```text
Target Health
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

The intentional application failure test demonstrated the complete lifecycle:

```text
Healthy
   |
   v
Application Failure
   |
   v
Target Unhealthy
   |
   v
CloudWatch ALARM
   |
   v
Notification
   |
   v
Application Recovery
   |
   v
Target Healthy
   |
   v
CloudWatch OK
```

This makes the ALB a central component connecting application deployment, health validation, traffic routing, and monitoring.

---

## Visual Evidence

Screenshots are embedded next to the relevant implementation and validation sections above. The complete screenshot library is available in the repository [`screenshots/`](../screenshots/).

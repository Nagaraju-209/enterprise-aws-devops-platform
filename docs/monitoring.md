# Monitoring

## Overview

The Enterprise AWS DevOps Platform includes an AWS-native monitoring and alerting layer built with:

- Amazon CloudWatch
- CloudWatch Logs
- CloudWatch Dashboard
- CloudWatch Alarms
- Amazon SNS
- Email notifications

The monitoring system observes EC2 and Application Load Balancer health and provides an operational alert path when important conditions occur.

The monitoring implementation was validated using an intentional application failure and subsequent recovery.

---

# 1. Monitoring Architecture

```text
                    +----------------------+
                    |      EC2 Instance    |
                    |----------------------|
                    | CPU                  |
                    | Memory               |
                    | Disk                 |
                    | Application          |
                    | Docker               |
                    +----------+-----------+
                               |
                               v
                     +-------------------+
                     |    CloudWatch     |
                     |-------------------|
                     | Metrics           |
                     | Logs              |
                     | Dashboard         |
                     | Alarms            |
                     +---------+---------+
                               |
                               v
                     +-------------------+
                     |       SNS         |
                     |-------------------|
                     | Email Topic       |
                     +---------+---------+
                               |
                               v
                         Email Alert
```

The Application Load Balancer is monitored alongside EC2:

```text
                Application Load Balancer
                           |
           +---------------+---------------+
           |               |               |
           v               v               v
       5xx Errors    Response Time    Target Health
           |               |               |
           +---------------+---------------+
                           |
                           v
                       CloudWatch
```

---

# 2. Monitoring Goals

The monitoring implementation is designed to:

- Observe EC2 resource health.
- Observe ALB application traffic and target health.
- Collect operational logs.
- Provide a centralized CloudWatch dashboard.
- Detect abnormal infrastructure conditions.
- Detect application availability problems through ALB target health.
- Generate alarms for important failure conditions.
- Send email notifications through SNS.
- Validate that alarms transition to `ALARM` during failures.
- Validate that alarms recover to `OK` after recovery.

---

# 3. Terraform Monitoring Resources

Monitoring is managed through Terraform.

The final monitoring implementation includes dedicated configuration for:

```text
terraform/
 |
 +-- cloudwatch-logs.tf
 |
 +-- cloudwatch-alarms.tf
 |
 +-- cloudwatch-dashboard.tf
 |
 +-- sns.tf
```

The exact Terraform resource names and configuration remain the source of truth for the deployed monitoring behavior.

---

# 4. CloudWatch Logs

CloudWatch Logs provides centralized log storage for the monitoring implementation.

The purpose is to make operational logs available through AWS rather than requiring an administrator to connect directly to EC2 for every investigation.

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

Log retention is configured through Terraform.

---

# 5. EC2 Monitoring

The monitoring implementation covers important EC2 resource metrics.

The monitored areas include:

```text
EC2
 |
 +-- CPU
 |
 +-- Memory
 |
 +-- Disk
```

These metrics provide visibility into resource pressure that could affect application availability.

---

# 6. EC2 CPU Monitoring

The project includes the alarm:

```text
enterprise-devops-ec2-high-cpu
```

The purpose of this alarm is to identify excessive CPU utilization on the EC2 instance.

Conceptually:

```text
EC2 CPU
   |
   v
CloudWatch Metric
   |
   v
CPU Alarm
   |
   +-- OK
   |
   +-- ALARM
```

An elevated CPU condition can indicate:

- High application workload
- Resource exhaustion
- Unexpected process activity
- Capacity constraints

The exact alarm threshold and evaluation settings are defined in Terraform and should be treated as the source of truth.

---

# 7. Memory Monitoring

Memory metrics are part of the monitoring design.

```text
EC2
 |
 v
Memory Metrics
 |
 v
CloudWatch
```

Memory visibility helps identify resource pressure that may not be apparent from CPU utilization alone.

---

# 8. Disk Monitoring

Disk metrics are also included.

```text
EC2
 |
 v
Disk Metrics
 |
 v
CloudWatch
```

Disk monitoring is useful for identifying:

- Low available disk capacity
- Log growth
- Container/image storage pressure
- General filesystem utilization

---

# 9. Application Load Balancer Monitoring

The ALB is a critical part of the application's availability path.

The monitoring implementation covers:

```text
ALB
 |
 +-- 5xx Errors
 |
 +-- Response Time
 |
 +-- Healthy Targets
 |
 +-- Unhealthy Targets
```

These metrics help identify both application failures and traffic-serving problems.

---

# 10. ALB 5xx Error Alarm

The final monitoring implementation includes:

```text
enterprise-devops-alb-5xx-errors
```

This alarm monitors ALB-side server error behavior.

Conceptually:

```text
ALB 5xx Errors
       |
       v
CloudWatch
       |
       v
5xx Alarm
       |
       +-- OK
       |
       +-- ALARM
```

A sustained increase in 5xx responses can indicate problems with the application or backend target.

---

# 11. ALB High Response Time Alarm

The project includes:

```text
enterprise-devops-alb-high-response-time
```

This alarm is intended to detect elevated response times.

Conceptually:

```text
Request
   |
   v
ALB
   |
   v
Response Time
   |
   v
CloudWatch
   |
   v
Response-Time Alarm
```

High response time can indicate:

- Application slowness
- Resource pressure
- Backend performance problems
- Unexpected workload

The exact threshold and evaluation configuration are defined in Terraform.

---

# 12. No Healthy Targets Alarm

The project includes:

```text
enterprise-devops-alb-no-healthy-targets
```

This alarm detects the critical condition where the target group has no healthy targets.

The operational flow is:

```text
ALB Target Group
       |
       v
Healthy Targets = 0
       |
       v
CloudWatch Alarm
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

This is an important application-availability alarm because the ALB cannot successfully route application traffic when no target is healthy.

---

# 13. Unhealthy Targets Alarm

The project also includes:

```text
enterprise-devops-alb-unhealthy-targets
```

This alarm monitors unhealthy target behavior.

The distinction between the two target-health alarms is operationally useful:

```text
No Healthy Targets
        |
        v
Zero healthy targets

Unhealthy Targets
        |
        v
Target health degradation
```

Both conditions are useful for detecting application availability problems.

---

# 14. Final Alarm Set

The final CloudWatch alarm set is:

```text
+------------------------------------------------------+
|                 CloudWatch Alarms                    |
+------------------------------------------------------+
| enterprise-devops-ec2-high-cpu                       |
| enterprise-devops-alb-5xx-errors                    |
| enterprise-devops-alb-high-response-time            |
| enterprise-devops-alb-no-healthy-targets            |
| enterprise-devops-alb-unhealthy-targets             |
+------------------------------------------------------+
```

These alarms provide coverage across:

```text
EC2 Resource Health
        +
ALB Error Health
        +
ALB Performance
        +
ALB Target Availability
```

---

# 15. CloudWatch Dashboard

A dedicated CloudWatch dashboard is part of the final monitoring implementation.

The dashboard provides a centralized operational view of relevant infrastructure and application health metrics.

Conceptually:

```text
+----------------------------------------------------+
|          Enterprise DevOps Monitoring              |
+----------------------------------------------------+
|                                                    |
| EC2 CPU                                            |
|                                                    |
+----------------------------------------------------+
|                                                    |
| ALB 5xx Errors                                     |
|                                                    |
+----------------------------------------------------+
|                                                    |
| ALB Response Time                                  |
|                                                    |
+----------------------------------------------------+
|                                                    |
| Target Health                                      |
|                                                    |
+----------------------------------------------------+
```

The actual widgets and metric dimensions are defined by the Terraform dashboard configuration.

---

# 16. SNS Alerting

CloudWatch alarms integrate with Amazon SNS.

```text
CloudWatch Metric
       |
       v
CloudWatch Alarm
       |
       v
SNS Topic
       |
       v
Email Subscription
       |
       v
Email
```

The project successfully confirmed the SNS email subscription during validation.

---

# 17. Email Notification Flow

The notification path is:

```text
Failure Condition
       |
       v
CloudWatch Metric
       |
       v
Alarm -> ALARM
       |
       v
SNS Topic
       |
       v
Email
```

Recovery follows the reverse operational state transition:

```text
Failure Recovered
       |
       v
Metric Returns to Normal
       |
       v
Alarm -> OK
```

Depending on the configured SNS/alarm actions, alarm and recovery state changes can generate corresponding notifications.

---

# 18. SNS Subscription Confirmation

SNS email subscriptions require confirmation.

The project validation included successful subscription confirmation.

The confirmed subscription established the notification path:

```text
SNS Topic
    |
    v
Email Subscription
    |
    v
Confirmed
```

Without confirmation, the email endpoint cannot receive the intended SNS notifications.

---

# 19. Failure Testing

The monitoring system was tested against a real application failure rather than only checking that the alarm resources existed.

The application container was intentionally stopped.

The test condition was:

```text
enterprise-app
        |
        v
Intentionally stopped
```

---

# 20. Failure Detection Flow

The intentional application failure produced the expected operational behavior:

```text
Application Container Stopped
            |
            v
Application Unavailable
            |
            v
ALB Health Check Fails
            |
            v
Target Becomes Unhealthy
            |
            v
CloudWatch Alarm
            |
            v
ALARM
            |
            v
SNS Notification
            |
            v
Email
```

This validates the complete monitoring chain.

---

# 21. ALB Unhealthy State

When the application was stopped, the ALB target became unhealthy.

The relevant alarms entered:

```text
enterprise-devops-alb-no-healthy-targets
        |
        v
ALARM
```

and:

```text
enterprise-devops-alb-unhealthy-targets
        |
        v
ALARM
```

This confirmed that the ALB health-check mechanism was correctly connected to the monitoring layer.

---

# 22. Recovery Testing

After the application was restored through deployment/recovery, the ALB target returned to:

```text
healthy
```

The CloudWatch alarms then returned to:

```text
OK
```

The recovery flow was:

```text
Application Restored
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

This demonstrated both failure detection and recovery.

---

# 23. Alarm State Lifecycle

The monitoring lifecycle can be represented as:

```text
                 Normal
                   |
                   v
                  OK
                   |
                   | Failure condition
                   v
                ALARM
                   |
                   v
             SNS Notification
                   |
                   |
             Recovery occurs
                   |
                   v
                  OK
```

This state transition is the core behavior validated during failure testing.

---

# 24. Monitoring Validation

The final implementation was validated through:

```text
[✓] CloudWatch monitoring resources
[✓] CloudWatch dashboard
[✓] EC2 CPU monitoring
[✓] Memory monitoring
[✓] Disk monitoring
[✓] ALB 5xx monitoring
[✓] ALB response-time monitoring
[✓] ALB target-health monitoring
[✓] CloudWatch alarms
[✓] SNS topic
[✓] SNS email subscription
[✓] Intentional application failure
[✓] ALB unhealthy detection
[✓] Alarm transition to ALARM
[✓] SNS notification path
[✓] Application recovery
[✓] ALB healthy state
[✓] Alarm recovery to OK
```

At final validation, the configured alarms were confirmed to be in the healthy `OK` state after recovery.

---

# 25. Monitoring and CI/CD Integration

Monitoring is integrated with the deployment pipeline.

```text
                  GitHub Actions
                        |
                        v
                  Deploy via SSM
                        |
                        v
                       EC2
                        |
                        v
                 Docker Application
                        |
                        v
                       ALB
                        |
                        v
                  Health Checks
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

Deployment validation therefore extends beyond:

```text
SSM command = Success
```

and includes:

```text
Container = Running
Application = Healthy
ALB Target = Healthy
Alarms = OK
```

---

# 26. Monitoring and Application Health

The monitoring system observes application health indirectly through the ALB.

```text
Spring Boot
    |
    v
/health
    |
    v
ALB Health Check
    |
    v
Target Health
    |
    v
CloudWatch
```

This creates a clear chain from application availability to infrastructure monitoring.

---

# 27. Troubleshooting with CloudWatch

CloudWatch provides an operational starting point when investigating application problems.

A practical investigation flow is:

```text
Alarm
  |
  v
Identify Metric
  |
  v
Check ALB Target Health
  |
  v
Check Application Container
  |
  v
Check Application Logs
  |
  v
Check EC2 Resource Metrics
  |
  v
Identify Root Cause
```

This avoids relying on a single metric when diagnosing an incident.

---

# 28. Example: No Healthy Targets

If:

```text
enterprise-devops-alb-no-healthy-targets
```

enters `ALARM`, investigate in this order:

```text
1. Check ALB target health
        |
        v
2. Check EC2 instance status
        |
        v
3. Check Docker container
        |
        v
4. Check application logs
        |
        v
5. Check /health endpoint
        |
        v
6. Check port 8083
        |
        v
7. Check security groups
```

This separates application failures from networking and infrastructure failures.

---

# 29. Example: High Response Time

If:

```text
enterprise-devops-alb-high-response-time
```

enters `ALARM`, investigate:

```text
ALB response time
        |
        v
EC2 CPU
        |
        v
EC2 memory
        |
        v
Application logs
        |
        v
Application behavior
```

The goal is to determine whether latency originates from:

- Resource pressure
- Application processing
- Dependency calls
- Traffic/load
- Infrastructure limitations

The exact diagnosis depends on the observed metrics and logs.

---

# 30. Example: ALB 5xx Errors

If:

```text
enterprise-devops-alb-5xx-errors
```

enters `ALARM`, investigate:

```text
ALB 5xx
   |
   v
Target Health
   |
   v
Application Health
   |
   v
Container Logs
   |
   v
Application Logs
```

The ALB metric alone indicates an error condition; the surrounding metrics and logs are needed to identify the root cause.

---

# 31. Intentional Failure Test

The project deliberately stopped the application container:

```text
enterprise-app
```

This was used to validate the monitoring chain.

The observed sequence was:

```text
Container stopped
      |
      v
ALB target unhealthy
      |
      v
No healthy target condition
      |
      v
CloudWatch ALARM
      |
      v
SNS alert
```

After recovery:

```text
Container running
      |
      v
ALB target healthy
      |
      v
CloudWatch OK
```

This provides practical evidence that the monitoring implementation works under an actual failure condition.

---

# 32. SSM Incident and Monitoring

The project also experienced an SSM deployment incident.

An SSM command remained in:

```text
InProgress
```

The SSM Agent logs showed an old command being resumed after the EC2 reboot.

The important point for monitoring is that:

```text
SSM Agent Health
        !=
SSM Command Success
        !=
Application Health
        !=
ALB Health
```

These are separate operational layers.

The incident was diagnosed by examining the SSM Agent logs and validating the AWS Systems Manager control channel separately.

After recovery, the deployment succeeded and the application returned to a healthy ALB state.

---

# 33. Monitoring Security

Monitoring resources are managed using Terraform.

The project avoids storing sensitive credentials directly in application code.

SNS provides notification delivery without requiring the application to implement its own email service.

CloudWatch and SNS access is controlled through AWS IAM.

---

# 34. Monitoring as Code

The monitoring configuration is version-controlled.

This provides:

- Reproducibility
- Reviewability
- Change history
- Consistent environments
- Easier recovery

The monitoring configuration can be recreated as part of the Terraform infrastructure.

Conceptually:

```text
Terraform
    |
    +-- CloudWatch Logs
    |
    +-- Dashboard
    |
    +-- Alarms
    |
    +-- SNS
```

---

# 35. Final Monitoring Architecture

```text
                         APPLICATION
                              |
                              v
                         Docker / EC2
                              |
              +---------------+---------------+
              |                               |
              v                               v
          Application                     EC2 Metrics
             Logs                              |
              |                                |
              +---------------+----------------+
                              |
                              v
                         CloudWatch
                              |
              +---------------+---------------+
              |               |               |
              v               v               v
             Logs          Dashboard        Alarms
                                              |
                             +----------------+----------------+
                             |                |               |
                             v                v               v
                           CPU             ALB 5xx        Target Health
                                                              |
                                                              v
                                                             SNS
                                                              |
                                                              v
                                                            Email
```

---

# 36. Final Monitoring State

After the final application recovery:

```text
EC2 Monitoring       -> Healthy
ALB Target           -> Healthy
CloudWatch Alarms    -> OK
SNS Subscription     -> Confirmed
Application          -> Running
```

The AWS infrastructure was subsequently destroyed after the project was fully validated.

Therefore:

```text
Monitoring Configuration -> Preserved in Terraform
AWS Monitoring Resources -> Destroyed with infrastructure
Documentation            -> Preserved
Git History              -> Preserved
```

---

# 37. Recreating Monitoring

When the infrastructure is recreated with Terraform:

```bash
cd terraform

terraform init

terraform plan

terraform apply
```

Terraform recreates the monitoring resources defined in the configuration.

After deployment, verify:

```text
CloudWatch Dashboard
CloudWatch Alarms
CloudWatch Logs
SNS Topic
SNS Subscription
```

The exact current resource names, thresholds, periods, dimensions, and retention values should be taken from the Terraform configuration.

---

# 38. Monitoring Validation Checklist

Use this checklist after recreating the infrastructure:

```text
[ ] CloudWatch log groups exist
[ ] CloudWatch dashboard exists
[ ] EC2 metrics are available
[ ] ALB metrics are available
[ ] CPU alarm exists
[ ] ALB 5xx alarm exists
[ ] Response-time alarm exists
[ ] No-healthy-targets alarm exists
[ ] Unhealthy-targets alarm exists
[ ] SNS topic exists
[ ] Email subscription is confirmed
[ ] ALB target is healthy
[ ] Application /health returns 200
[ ] Alarm states are OK
```

For failure testing:

```text
[ ] Stop application container
[ ] Confirm ALB target becomes unhealthy
[ ] Confirm target-health alarm enters ALARM
[ ] Confirm SNS notification
[ ] Restore application
[ ] Confirm ALB target becomes healthy
[ ] Confirm alarms return to OK
```

---

# 39. Final Monitoring Summary

The monitoring implementation provides an AWS-native operational feedback loop:

```text
              APPLICATION
                   |
                   v
              HEALTH STATE
                   |
                   v
                  ALB
                   |
                   v
              CLOUDWATCH
                   |
          +--------+--------+
          |        |        |
          v        v        v
        LOGS    METRICS   ALARMS
                            |
                            v
                           SNS
                            |
                            v
                          EMAIL
```

The project does not treat monitoring as a configuration-only exercise.

It was validated through an intentional failure:

```text
Failure
   |
   v
Detection
   |
   v
ALARM
   |
   v
Notification
   |
   v
Recovery
   |
   v
OK
```

This demonstrates the complete monitoring and alerting lifecycle for the Enterprise AWS DevOps Platform.

---

# 40. Final Project Status

Monitoring is a completed project capability.

Validated components:

```text
CloudWatch Logs       -> Completed
CloudWatch Dashboard  -> Completed
EC2 Monitoring        -> Completed
ALB Monitoring        -> Completed
CloudWatch Alarms     -> Completed
SNS Alerting          -> Completed
Email Confirmation    -> Completed
Failure Testing       -> Completed
Recovery Testing      -> Completed
```

The monitoring infrastructure is preserved as Terraform configuration so that the environment can be recreated in the future without relying on manual AWS Console configuration.

---

## Visual Evidence

Screenshots are embedded next to the relevant implementation and validation sections above. The complete screenshot library is available in the repository [`screenshots/`](../screenshots/).

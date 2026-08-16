# Failure and Recovery

## Overview

The Enterprise AWS DevOps Platform was intentionally tested under failure conditions to verify that deployment, application health, Application Load Balancer health checks, CloudWatch alarms, SNS notifications, and recovery behavior worked together.

This document records the actual failure and recovery scenarios encountered and validated during the project.

The most important validated lifecycle was:

```text
Healthy Application
        |
        v
Intentional Failure
        |
        v
ALB Target Unhealthy
        |
        v
CloudWatch Alarm -> ALARM
        |
        v
SNS Notification
        |
        v
Application Recovery
        |
        v
ALB Target Healthy
        |
        v
CloudWatch Alarm -> OK
```

A separate AWS Systems Manager deployment incident was also investigated:

```text
SSM Deployment
      |
      v
InProgress / Timeout
      |
      v
SSM Agent Investigation
      |
      v
Stale Command / IPC Timeout
      |
      v
Agent + Connectivity Validation
      |
      v
Recovery
      |
      v
Successful Deployment
```

---

# 1. Failure-Recovery Objectives

The failure-recovery testing was designed to verify that the platform could:

- Detect application failure.
- Detect ALB target-health degradation.
- Trigger CloudWatch alarms.
- Send SNS notifications.
- Restore the application.
- Recover ALB target health.
- Return alarms to `OK`.
- Diagnose SSM deployment failures.
- Distinguish infrastructure health from application health.
- Validate recovery through multiple independent signals.

---

# 2. Recovery Architecture

```text
                    +------------------+
                    |    GitHub        |
                    +--------+---------+
                             |
                             v
                    +------------------+
                    | GitHub Actions    |
                    +--------+---------+
                             |
                             v
                           SSM
                             |
                             v
                    +------------------+
                    |       EC2        |
                    |                  |
                    | Docker           |
                    | enterprise-app   |
                    +--------+---------+
                             |
                             v
                    +------------------+
                    |       ALB        |
                    +--------+---------+
                             |
                             v
                       Health Check
                          /health
                             |
                 +-----------+-----------+
                 |                       |
                 v                       v
              Healthy                Unhealthy
                 |                       |
                 v                       v
             CloudWatch              CloudWatch
                 |                       |
                 v                       v
                OK                    ALARM
                                         |
                                         v
                                        SNS
                                         |
                                         v
                                       Email
```

---

# 3. Normal State

Before failure testing, the application was operating normally.

The expected state was:

```text
EC2                  -> Running
Docker               -> Running
enterprise-app       -> Running
Application          -> Healthy
ALB Target           -> healthy
CloudWatch Alarms    -> OK
SNS Subscription     -> Confirmed
```

The ALB target used:

```text
Port: 8083
Health Path: /health
```

---

# 4. Normal Traffic Flow

The normal request path is:

```text
Client
  |
  v
Application Load Balancer
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
enterprise-app
  |
  v
Spring Boot
  |
  v
/health
```

When the health check succeeds:

```text
ALB Target = healthy
```

---

# 5. Intentional Application Failure

The main failure test intentionally stopped the application container.

The container was:

```text
enterprise-app
```

The SSM command output confirmed:

```text
enterprise-app
Application container intentionally stopped for monitoring test
```

This was an intentional failure and was used to verify the monitoring system.

---

# 6. Failure Sequence

The intentional failure produced this sequence:

```text
enterprise-app stopped
        |
        v
Application unavailable
        |
        v
ALB health check fails
        |
        v
Target becomes unhealthy
        |
        v
CloudWatch detects target condition
        |
        v
Alarm enters ALARM
        |
        v
SNS notification path
```

This validated that the monitoring system reacted to an actual application failure.

---

# 7. ALB Target Health During Failure

When the application container stopped, the ALB could no longer receive a successful response from:

```text
/health
```

The target therefore changed from:

```text
healthy
```

to:

```text
unhealthy
```

This demonstrates the relationship:

```text
Application Availability
        |
        v
ALB Health Check
        |
        v
Target Health
```

---

# 8. No Healthy Targets Alarm

The project includes:

```text
enterprise-devops-alb-no-healthy-targets
```

When the application was intentionally stopped and there were no healthy targets, the alarm entered:

```text
ALARM
```

The operational chain was:

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

# 9. Unhealthy Targets Alarm

The project also includes:

```text
enterprise-devops-alb-unhealthy-targets
```

This alarm also entered:

```text
ALARM
```

during the intentional target-health failure.

This provided a second monitoring signal for the same availability incident.

---

# 10. Alarm State Transition

The failure test demonstrated:

```text
Normal
  |
  v
OK
  |
  | Application failure
  v
ALARM
```

After recovery:

```text
ALARM
  |
  | Application restored
  v
OK
```

The complete lifecycle was therefore validated.

---

# 11. SNS Notification Path

The monitoring architecture uses Amazon SNS.

The notification path is:

```text
Application Failure
       |
       v
ALB Target Unhealthy
       |
       v
CloudWatch Alarm
       |
       v
SNS Topic
       |
       v
Confirmed Email Subscription
       |
       v
Email Notification
```

The SNS email subscription was successfully confirmed during the project.

---

# 12. SNS Subscription Incident

During the project, the email subscription was accidentally unsubscribed after it had been confirmed.

Terraform subsequently detected that the subscription needed to be created again:

```text
Plan: 1 to add, 0 to change, 0 to destroy
```

The resource was:

```text
aws_sns_topic_subscription.monitoring_email
```

The topic was:

```text
enterprise-devops-monitoring-alerts
```

The subscription was then confirmed again successfully.

---

# 13. SNS Recovery

The SNS subscription confirmation email indicated successful subscription.

The subscription ARN was returned by AWS.

This restored the notification path:

```text
CloudWatch
    |
    v
SNS
    |
    v
Email
```

The important operational lesson was that an SNS email subscription has its own lifecycle and must remain confirmed for email notifications to work.

---

# 14. Application Recovery

After the failure test, the application was restored.

The expected recovery sequence was:

```text
Docker Container
       |
       v
enterprise-app running
       |
       v
Spring Boot started
       |
       v
/health returns 200
       |
       v
ALB target healthy
```

---

# 15. ALB Recovery

After the application returned, the target health recovered:

```text
Port 8083
State healthy
```

This confirmed that the ALB health-check system correctly recognized the application recovery.

---

# 16. CloudWatch Recovery

After the target became healthy again, the relevant alarms returned to:

```text
OK
```

The final state was:

```text
enterprise-devops-alb-no-healthy-targets -> OK
enterprise-devops-alb-unhealthy-targets  -> OK
```

The complete monitoring recovery was therefore validated.

---

# 17. Recovery Validation

Recovery was validated across multiple layers:

```text
Layer 1
Docker
    |
    v
Container Running

Layer 2
Application
    |
    v
/health = 200

Layer 3
ALB
    |
    v
Target = healthy

Layer 4
CloudWatch
    |
    v
Alarm = OK
```

This is stronger than checking only the container status.

---

# 18. Why Multiple Recovery Checks Matter

A container can be running while the application is still unhealthy.

For example:

```text
Container = Running
Application = Failed
ALB Target = Unhealthy
```

Therefore, the project uses layered validation:

```text
Container
   +
Application
   +
ALB
   +
CloudWatch
```

A complete recovery requires all relevant layers to return to normal.

---

# 19. SSM Deployment Failure

A separate failure occurred during CI/CD deployment.

GitHub Actions reported:

```text
SSM deployment timed out.
Process completed with exit code 1.
```

The corresponding SSM command initially remained:

```text
InProgress
```

The command did not immediately produce normal deployment output.

---

# 20. SSM Command State

The SSM command was observed with:

```json
{
  "Status": "InProgress"
}
```

The command was associated with the EC2 instance:

```text
i-0b4f4c5039cc5dc82
```

The investigation had to distinguish between:

```text
SSM service connectivity
```

and:

```text
SSM command execution state
```

---

# 21. EC2 Reboot During SSM Investigation

The EC2 instance was rebooted while troubleshooting the stuck command.

After reboot, the SSM Agent started successfully.

The service showed:

```text
amazon-ssm-agent.service
Active: active (running)
```

This demonstrated that the agent itself was operational after the reboot.

---

# 22. SSM Agent Credential Validation

The SSM Agent logs showed:

```text
EC2RoleProvider Successfully connected with instance profile role credentials
```

This confirmed that the EC2 instance could obtain credentials through its instance profile.

The credential path was:

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
```

---

# 23. SSM Agent Identity Validation

The SSM Agent logs showed:

```text
Agent will take identity from EC2
```

and:

```text
Registration info found for ec2 instance
```

This confirmed that the agent recognized the EC2 identity.

---

# 24. SSM Control Channel Validation

The agent successfully established the Systems Manager control channel.

The logs showed:

```text
Opening websocket connection to:
wss://ssmmessages.ap-south-1.amazonaws.com/...
```

followed by:

```text
Successfully opened websocket connection
```

and:

```text
Set up control channel successfully
```

Therefore:

```text
SSM Connectivity = Working
```

---

# 25. SSM Endpoint Connectivity

The EC2 host was also able to reach:

```text
ssmmessages.ap-south-1.amazonaws.com
```

A direct HTTP request returned:

```text
HTTP/1.1 400 Bad Request
```

This did not represent an SSM service outage.

It demonstrated that the endpoint was reachable, although the direct request was not a valid SSM API request.

The stronger evidence was the successful WebSocket connection recorded by the SSM Agent.

---

# 26. Stale SSM Command

The SSM Agent found the previous command after reboot:

```text
Found in-progress document
```

The agent attempted to process the command again.

The logs showed:

```text
Processing in-progress document
```

This indicated that the old command state persisted across the reboot.

---

# 27. Stale Process Detection

The SSM Agent then reported:

```text
process: 33207 not found, treat as exited
```

The agent attempted to continue processing the command, but the original process was no longer available.

This created a stale command execution condition.

---

# 28. SSM IPC Timeout

The SSM Agent eventually reported:

```text
ipc messaging received timedout signal!
```

followed by:

```text
messaging worker encountered error:
ipc messaging received timeout signal
```

The document state at that point was:

```text
InProgress
```

The agent then marked the execution as failed.

---

# 29. SSM Failure Result

The final SSM runtime result showed:

```text
documentStatus: Failed
```

with:

```text
runtimeStatusCounts:
  Failed: 1
```

and:

```text
document process failed unexpectedly:
ipc messaging received timeout signal
```

The important conclusion was:

```text
SSM Agent = Healthy
SSM Network = Healthy
SSM Credentials = Healthy
Old Command Execution = Failed
```

---

# 30. SSM Recovery Process

The recovery process included:

```text
1. Cancel stale command
       |
       v
2. Reboot EC2
       |
       v
3. Verify SSM Agent
       |
       v
4. Verify instance credentials
       |
       v
5. Verify SSM connectivity
       |
       v
6. Retry deployment
       |
       v
7. Validate application
       |
       v
8. Validate ALB
```

After recovery, the CI/CD workflow succeeded and the ALB became healthy.

---

# 31. SSM vs Application Health

The incident demonstrated that these are independent states:

```text
EC2 Health
    !=
SSM Agent Health
    !=
SSM Command Health
    !=
Application Health
    !=
ALB Target Health
```

For example, during the incident:

```text
EC2             -> Running
SSM Agent       -> Running
SSM Connectivity-> Working
SSM Command     -> Failed/Stuck
Application     -> Required Validation
ALB             -> Required Validation
```

This distinction is important when troubleshooting deployment failures.

---

# 32. Successful Deployment Recovery

After the SSM issue was resolved, the workflow successfully deployed the application.

The final operational state was:

```text
GitHub Actions -> Success
SSM            -> Success
EC2            -> Running
Docker         -> Running
Application    -> Running
ALB Target     -> healthy
CloudWatch     -> OK
```

---

# 33. Deployment Failure Recovery Model

The project follows this general model:

```text
Deployment Failure
       |
       v
Identify Failed Layer
       |
       +-- GitHub Actions
       |
       +-- Maven
       |
       +-- Docker
       |
       +-- ECR
       |
       +-- SSM
       |
       +-- Application
       |
       +-- ALB
       |
       +-- CloudWatch
       |
       v
Recover Specific Layer
       |
       v
Validate Downstream Layers
```

---

# 34. Application Failure Recovery Model

For an application failure:

```text
Alarm
  |
  v
Check ALB Target
  |
  v
Check EC2
  |
  v
Check Docker
  |
  v
Check Application Logs
  |
  v
Restore Application
  |
  v
Check /health
  |
  v
Check ALB
  |
  v
Check CloudWatch
```

---

# 35. Failure Detection Checklist

When an application failure occurs:

```text
[ ] Check CloudWatch alarm
[ ] Check ALB target health
[ ] Check EC2 instance
[ ] Check Docker container
[ ] Check application logs
[ ] Check application health endpoint
[ ] Check security groups if required
[ ] Check SSM deployment state if failure followed deployment
```

---

# 36. Container Investigation

Use:

```bash
docker ps
```

to determine whether the application container is running.

If it is not present:

```bash
docker ps -a
```

Then inspect:

```bash
docker logs enterprise-app
```

The container name is:

```text
enterprise-app
```

---

# 37. Application Log Investigation

Application logs can reveal:

- Startup failure
- Java exceptions
- Configuration problems
- Dependency failures
- Port binding problems
- Database connection failures

Command:

```bash
docker logs enterprise-app
```

The application should not be considered recovered until it successfully responds to the expected health endpoint.

---

# 38. ALB Investigation

Check target health using:

```bash
aws elbv2 describe-target-health \
  --target-group-arn "<target-group-arn>" \
  --query 'TargetHealthDescriptions[].{Target:Target.Id,Port:Target.Port,State:TargetHealth.State,Reason:TargetHealth.Reason}' \
  --output table
```

Expected recovered state:

```text
Port   State
8083   healthy
```

---

# 39. CloudWatch Investigation

When an alarm fires, determine:

```text
Which Alarm?
     |
     v
Which Metric?
     |
     v
What Changed?
     |
     v
Is Application Healthy?
     |
     v
Is ALB Healthy?
```

Relevant project alarms:

```text
enterprise-devops-ec2-high-cpu
enterprise-devops-alb-5xx-errors
enterprise-devops-alb-high-response-time
enterprise-devops-alb-no-healthy-targets
enterprise-devops-alb-unhealthy-targets
```

---

# 40. SNS Investigation

If an alarm enters `ALARM` but no email arrives:

```text
1. Check alarm state
       |
       v
2. Check alarm action
       |
       v
3. Check SNS topic
       |
       v
4. Check subscription
       |
       v
5. Check subscription confirmation
```

A confirmed subscription is required for the expected email notification behavior.

---

# 41. Recovery Verification Matrix

| Layer | Failure State | Recovery State |
|---|---|---|
| EC2 | Unavailable / rebooting | Running |
| SSM Agent | Disconnected | Active |
| SSM Command | InProgress/Failed | Success |
| Docker | Container stopped | Container running |
| Application | Unavailable | Healthy |
| ALB Target | Unhealthy | Healthy |
| CloudWatch | ALARM | OK |
| SNS | Notification path | Confirmed/available |

---

# 42. Intentional Failure Test Results

The project intentionally stopped:

```text
enterprise-app
```

Observed:

```text
ALB Target
    -> unhealthy

enterprise-devops-alb-no-healthy-targets
    -> ALARM

enterprise-devops-alb-unhealthy-targets
    -> ALARM
```

After restoration:

```text
ALB Target
    -> healthy

CloudWatch alarms
    -> OK
```

This is the primary failure-recovery validation of the platform.

---

# 43. Recovery Is Not Complete Until Monitoring Recovers

The application may be running again while an alarm is still transitioning.

Therefore, final recovery validation should be:

```text
Application = Healthy
       +
ALB Target = healthy
       +
CloudWatch = OK
```

The project used this layered validation.

---

# 44. Deployment Recovery Is Not Complete Until ALB Recovers

Similarly:

```text
SSM = Success
```

is not enough.

The final deployment state should be:

```text
SSM = Success
   |
   v
Container = Running
   |
   v
Application = Healthy
   |
   v
ALB = healthy
```

This avoids declaring a deployment successful when the application is still unavailable.

---

# 45. Security During Recovery

Recovery operations should not introduce permanent security exposure.

During troubleshooting, SSH was temporarily restricted to:

```text
49.15.207.58/32
```

The temporary access was removed afterward.

The normal deployment path remains:

```text
GitHub Actions
      |
      v
SSM
      |
      v
EC2
```

---

# 46. Recovery and Least Privilege

Troubleshooting access should be:

```text
Temporary
Restricted
Audited
Removed
```

Avoid:

```text
0.0.0.0/0
```

for administrative access unless there is a specific, controlled requirement.

The project used a `/32` source restriction for temporary SSH access.

---

# 47. Recovery and Terraform

The infrastructure is managed through Terraform.

After recovery-related changes, verify:

```bash
terraform plan
```

The desired result is:

```text
No changes.
Your infrastructure matches the configuration.
```

This confirms that manual troubleshooting did not leave unintended infrastructure drift.

---

# 48. Failure-Recovery Validation with Terraform

A recommended validation sequence is:

```bash
terraform fmt
terraform validate
terraform plan
```

Then inspect:

```text
Security Groups
ALB
Target Group
EC2
IAM
CloudWatch
SNS
```

The infrastructure should match the intended configuration.

---

# 49. Recovery and GitHub Actions

After resolving a deployment issue, the pipeline should be rerun.

Expected:

```text
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
ALB
       |
       v
Healthy
```

The final project workflow succeeded after the SSM issue was resolved.

---

# 50. Common Failure Scenarios

## Scenario A: Container Stopped

```text
Container stopped
      |
      v
ALB unhealthy
      |
      v
CloudWatch ALARM
      |
      v
Restore container
      |
      v
ALB healthy
      |
      v
CloudWatch OK
```

## Scenario B: SSM Stuck

```text
SSM InProgress
      |
      v
Check Agent
      |
      v
Check Credentials
      |
      v
Check Connectivity
      |
      v
Check Agent Logs
      |
      v
Clear stale state
      |
      v
Retry
```


> **Evidence — Successful deployment after recovery**
>
> ![Successful deployment after recovery](../screenshots/github-actions/end-to-end/github-actions-workflow-success.png)

## Scenario C: ALB Unhealthy After Deployment

```text
SSM Success
      |
      v
Check Docker
      |
      v
Check Application
      |
      v
Check /health
      |
      v
Check Security Group
      |
      v
Check ALB
```

---

# 51. Recovery Decision Tree

```text
Deployment/Application Problem
             |
             v
      Is EC2 running?
        /         \
      No           Yes
      |             |
   Recover EC2      v
                Is SSM healthy?
                  /       \
                No         Yes
                |           |
             Recover SSM    v
                        Is container running?
                         /           \
                       No             Yes
                       |               |
                    Redeploy           v
                                  Is /health OK?
                                    /       \
                                  No         Yes
                                  |           |
                              Fix app        v
                                      Is ALB healthy?
                                        /      \
                                      No        Yes
                                      |          |
                                   Fix ALB     Recovered
```

---

# 52. Recovery Evidence

The project retained operational evidence through:

```text
Git history
Terraform plans
Terraform state
SSM command output
SSM Agent logs
Docker output
ALB target-health output
CloudWatch alarm states
SNS confirmation
```

This provides traceability from failure to recovery.

---

# 53. Final Healthy State

After all failures were resolved:

```text
GitHub Actions
      -> Success

SSM
      -> Success

EC2
      -> Running

Docker
      -> Running

enterprise-app
      -> Running

ALB
      -> Healthy

CloudWatch
      -> OK

SNS
      -> Confirmed
```

---

# 54. Project Teardown After Recovery

After all deployment, monitoring, failure, and recovery tests were completed, the temporary AWS infrastructure was destroyed.

The lifecycle was:

```text
Build
  |
  v
Deploy
  |
  v
Monitor
  |
  v
Failure Test
  |
  v
Recover
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

Terraform state was ultimately empty.

---

# 55. Recreating the Failure Test

When the infrastructure is recreated, the failure test can be repeated.

Normal state:

```text
ALB Target = healthy
```

Then intentionally stop the application:

```bash
docker stop enterprise-app
```

Expected:

```text
ALB Target -> unhealthy
```

Then restore the application through the normal deployment process.

Expected:

```text
ALB Target -> healthy
CloudWatch -> OK
```

The exact CloudWatch alarm transition depends on the configured alarm thresholds and evaluation periods.

---

# 56. Recovery Test Checklist

```text
[ ] Application initially healthy
[ ] ALB target initially healthy
[ ] CloudWatch alarms initially OK
[ ] SNS subscription confirmed
[ ] Stop application container
[ ] Observe ALB target becomes unhealthy
[ ] Observe target-health alarm
[ ] Observe no-healthy-target alarm where applicable
[ ] Confirm notification path
[ ] Restore application
[ ] Verify container running
[ ] Verify /health
[ ] Verify ALB target healthy
[ ] Verify CloudWatch alarms return to OK
```

---

# 57. SSM Failure Test Checklist

```text
[ ] Start with healthy EC2
[ ] Confirm SSM Agent active
[ ] Confirm instance is managed
[ ] Trigger deployment
[ ] Observe command state
[ ] If stuck, inspect get-command-invocation
[ ] Inspect SSM Agent logs
[ ] Check IAM credentials
[ ] Check SSM endpoint connectivity
[ ] Cancel stale command if necessary
[ ] Reboot only when appropriate
[ ] Verify SSM Agent after reboot
[ ] Retry deployment
[ ] Verify application
[ ] Verify ALB
```

---

# 58. Operational Lessons

The project demonstrated several important operational lessons.

### Lesson 1: Deployment success is not application success

```text
CI/CD = Success
```

does not automatically mean:

```text
Application = Healthy
```

### Lesson 2: Running container is not application health

```text
Docker = Running
```

does not automatically mean:

```text
/health = 200
```

### Lesson 3: SSM Agent health is not command health

```text
SSM Agent = Running
```

does not guarantee:

```text
SSM Command = Success
```

### Lesson 4: ALB health is a separate validation layer

```text
Application = Healthy
```

must be reflected in:

```text
ALB Target = healthy
```

### Lesson 5: Monitoring should be tested with real failures

The intentional container-stop test demonstrated the complete monitoring lifecycle rather than simply confirming that alarm resources existed.

---


> **Evidence — Target healthy before failure**
>
> ![Target healthy before failure](../screenshots/application-load-balancer/target-healthy.png)

> **Evidence — Target unhealthy during failure**
>
> ![Target unhealthy during failure](../screenshots/application-load-balancer/target-unhealthy.png)

# 59. Final Failure-Recovery Architecture

```text
                         SOURCE
                           |
                           v
                         GitHub
                           |
                           v
                    GitHub Actions
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
                    enterprise-app
                           |
                           v
                       Spring Boot
                           |
                           v
                          ALB
                           |
                     +-----+-----+
                     |           |
                     v           v
                  Healthy     Unhealthy
                     |           |
                     v           v
                   CloudWatch
                     |
              +------+------+
              |             |
              v             v
             OK           ALARM
                            |
                            v
                           SNS
                            |
                            v
                          Email
```

Recovery path:

```text
Failure
  |
  v
Detection
  |
  v
Investigation
  |
  v
Containment
  |
  v
Repair
  |
  v
Application Recovery
  |
  v
ALB Recovery
  |
  v
Alarm Recovery
  |
  v
Validation
```

---

# 60. Final Failure-Recovery Summary

The Enterprise AWS DevOps Platform was not only deployed successfully; it was deliberately tested under failure conditions.

The main validated failure scenario was:

```text
Application Container Stopped
```

which produced:

```text
ALB Target -> unhealthy
CloudWatch  -> ALARM
SNS         -> Notification Path
```

After recovery:

```text
Container -> Running
/health   -> Healthy
ALB       -> healthy
CloudWatch -> OK
```

The project also encountered and resolved an SSM deployment incident involving:

```text
InProgress
ConnectionLost / timeout symptoms
Stale in-progress document
Missing process
IPC messaging timeout
```

The investigation confirmed:

```text
EC2 IAM Credentials -> Working
SSM Agent            -> Running
SSM Control Channel  -> Working
SSM Command State    -> Failed/Stale
```

After clearing the stale execution condition and retrying the deployment, the workflow succeeded and the ALB returned to a healthy state.

---

# 61. Final Recovery State

At final validation:

```text
Application          -> Healthy
Docker               -> Running
ALB Target           -> healthy
CloudWatch Alarms    -> OK
SNS Subscription     -> Confirmed
CI/CD Workflow       -> Success
Terraform             -> No unintended changes
```

The AWS environment was then intentionally destroyed after the project was fully validated and documented.

The recovery architecture and test procedures remain preserved in the repository documentation for future recreation and demonstration.

---

## Visual Evidence

Screenshots are embedded next to the relevant implementation and validation sections above. The complete screenshot library is available in the repository [`screenshots/`](../screenshots/).

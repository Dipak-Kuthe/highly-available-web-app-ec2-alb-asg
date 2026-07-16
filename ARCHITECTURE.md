# Architecture — Highly Available Web App (EC2, ALB & Auto Scaling)

This diagram shows the highly available, self-healing web tier deployed on AWS.

```mermaid
flowchart TB
    U[User / Browser] -->|HTTP :80| ALB[Application Load Balancer]
    ALB --> TG[Target Group :80 - health check /]
    subgraph VPC[VPC - 2 Availability Zones]
      E1[EC2 - AZ a]
      E2[EC2 - AZ b]
    end
    TG --> E1
    TG --> E2
    ASG[Auto Scaling Group min 2 / max 4] --- E1
    ASG --- E2
    CW[CloudWatch CPU target-tracking] -->|scale in/out| ASG
```

## How it works

- The Application Load Balancer receives internet traffic on port 80 and distributes it across healthy EC2 targets.
- The Auto Scaling Group runs 2 to 4 instances across two Availability Zones for fault tolerance.
- CloudWatch target-tracking scaling adds or removes instances based on average CPU.
- If an instance or an entire AZ fails, the ALB routes traffic only to healthy instances in the other zone.

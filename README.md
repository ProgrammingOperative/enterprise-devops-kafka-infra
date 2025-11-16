# Self-Service Kafka Infrastructure — Terraform Repository

This repository forms the **foundation of an enterprise-grade self-service platform** for managing **Confluent Kafka resources** (topics, service accounts, ACLs) through **Terraform and GitOps automation**.  

The design emphasizes **security, governance, automation, and transparency**, serving as the central source of truth for all infrastructure changes.  

---

## Repository Overview

The infrastructure is modularized into **three main layers**, each serving a dedicated purpose:


---

## 1. Global Infrastructure (`aws_global_infra`)

This layer provides the **foundational backend services** for Terraform state management and locking.

### What it sets up
- **S3 bucket** for remote Terraform state storage  
- **DynamoDB table** for state locking and consistency  

### Purpose
- Ensures **state is shared, consistent, and version-controlled** across all teams.
- Enables **collaborative deployments** by preventing state corruption and enforcing locking.

### Initialization
Run this layer **first** to make state infrastructure available for the rest of the setup.

```bash
cd aws_global_infra
terraform init
terraform apply
```


## 2. Confluent Kafka Infrastructure (confluent_kafka_infra)

This layer provisions and manages all Kafka-related resources in Confluent Cloud.

What it handles:

- Kafka cluster provisioning

- Topics, Service Accounts, and ACLs

- API key management

- Outputs of created resources for downstream use
 
- Test out production and consumption to confluent

### Usage
```bash
cd confluent_kafka_infra
terraform init
terraform apply
```
Once resources are created, do a simple test to produce and consume from a created topic

```bash
terraform output --raw resource_ids
```
Then follow the instructions provided in the output

## CodePipeline Infrastructure (codepipeline_infra)

This layer automates Terraform execution via CI/CD and implements the GitOps workflow.

What it does

- Defines AWS CodePipeline and CodeBuild projects

- Automatically runs terraform plan and terraform apply on approved pull requests

- Integrates with the self-service GitHub repository

### Deployment
```bash
cd codepipeline_infra
terraform init
terraform apply
```

Every approved PR from the self-service repo triggers CodePipeline → CodeBuild → Terraform, ensuring a fully automated and auditable deployment flow.

NOTE: The aws_global_infra repo has to be created first before the rest, providing state store and lock infrastructure first.



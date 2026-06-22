# AWS Multi-Account AMI Deployment Automation Platform

## Overview

This project demonstrates a production-inspired AWS multi-account architecture for centralized AMI management and automated application deployment using Terraform, GitHub Actions, IAM Cross-Account Roles, EventBridge, and AWS Systems Manager Parameter Store.

The solution allows a Platform Account to publish approved AMIs while multiple Application Accounts automatically consume and deploy the latest approved image through secure cross-account access.

---

## Architecture

```text
                           ┌─────────────────────┐
                           │  Platform Account   │
                           │                     │
                           │ Latest Approved AMI │
                           │ Stored in SSM       │
                           └──────────┬──────────┘
                                      │
                                      │ Cross-Account Role
                                      ▼
                ┌──────────────────────────────────────────┐
                │                                          │
                ▼                                          ▼
      ┌───────────────────┐                    ┌───────────────────┐
      │   App Account 1   │                    │   App Account 2   │
      │                   │                    │                   │
      │ Terraform Deploy  │                    │ Terraform Deploy  │
      │ EC2 Workloads     │                    │ EC2 Workloads     │
      └─────────┬─────────┘                    └─────────┬─────────┘
                │                                          │
                └────────────────┬─────────────────────────┘
                                 ▼
                        GitHub Actions CI/CD
```

---

## Features

* Centralized AMI registry
* Cross-account AMI consumption
* Infrastructure as Code using Terraform
* GitHub Actions CI/CD automation
* GitHub OIDC authentication
* Event-driven deployment workflow
* Reusable Terraform modules
* Infrastructure drift detection
* Multi-account AWS architecture

---

## Repository Structure

```text
.
├── ANSWERS.md
├── README.md
├── app-account
│   ├── iam-github-oidc.tf
│   ├── main.tf
│   └── variables.tf
├── app-account2
│   ├── iam-github-oidc.tf
│   ├── main.tf
│   └── variables.tf
├── drift-detection
│   ├── main.tf
│   ├── output.tf
│   ├── terraform.tfvars.example
│   └── variables.tf
├── modules
│   ├── ec2-instance
│   └── remote-backend
└── platform-account
    ├── iam-platform.tf
    ├── main.tf
    ├── output.tf
    └── variables.tf
```

---

## Components

### Platform Account

The Platform Account acts as the central management account.

Responsibilities:

* Maintain approved AMIs
* Store latest AMI IDs in AWS Systems Manager Parameter Store
* Share AMIs across AWS accounts
* Provide cross-account IAM access
* Trigger deployment automation

Example Parameter:

```text
/platform/amis/frontend/latest
```

---

### Application Account 1

Deploys infrastructure using the latest approved AMI retrieved from the Platform Account.

Responsibilities:

* Assume CrossAccountAMIReaderRole
* Read approved AMI ID
* Deploy EC2 infrastructure
* Integrate with GitHub Actions

---

### Application Account 2

A second independent application environment consuming the same approved AMI from the Platform Account.

Responsibilities:

* Read approved AMI ID
* Deploy infrastructure
* Demonstrate multi-account scalability

---

### Terraform Modules

#### EC2 Instance Module

Reusable module responsible for:

* EC2 provisioning
* Standardized tagging
* Environment configuration
* AMI deployment

#### Remote Backend Module

Provides:

* Remote Terraform state storage
* State locking
* Team collaboration support

---

### Drift Detection

The drift-detection component validates whether deployed infrastructure is running the latest approved AMI.

Comparison:

```text
Current Running AMI
          vs
Latest Approved AMI
```

Outputs:

* Drift Detected
* Current AMI
* Latest Approved AMI
* Compliance Status

---

## Deployment Workflow

### Step 1

Platform team publishes a new approved AMI.

### Step 2

AMI ID is updated in Parameter Store.

```text
/platform/amis/frontend/latest
```

### Step 3

Application accounts retrieve the latest AMI through a cross-account IAM role.

### Step 4

GitHub Actions executes Terraform deployment.

### Step 5

Infrastructure is updated using the approved image.

---

## Security

### Cross-Account Access

Application accounts access approved AMIs through a dedicated IAM role.

Permissions are restricted to required operations only.

### GitHub OIDC Authentication

GitHub Actions uses OpenID Connect (OIDC) federation instead of long-lived AWS access keys.

Benefits:

* No stored AWS credentials
* Short-lived tokens
* Improved security posture

---

## Technologies Used

* AWS IAM
* AWS EC2
* AWS Systems Manager Parameter Store
* AWS EventBridge
* Terraform
* GitHub Actions
* OpenID Connect (OIDC)
* Cross-Account IAM Roles

---

## Learning Outcomes

This project demonstrates:

* Multi-account AWS design
* Cross-account IAM access
* Infrastructure as Code
* Terraform module development
* GitHub Actions CI/CD
* OIDC-based authentication
* Drift detection and compliance validation
* Secure cloud automation

---

## Author

**Pushpak Badadale**
Cloud | DevOps | Platform Engineering

# EC2 Instance Module

## Overview

This Terraform module provisions an AWS EC2 instance using an approved AMI supplied either directly through an AMI ID or retrieved from a centralized Systems Manager Parameter Store.

The module is designed to support multi-account deployments where application accounts consume approved AMIs published by a central Platform Account.

---

## Features

* EC2 instance provisioning
* Environment validation (dev/staging/prod)
* Standardized tagging strategy
* Centralized AMI management support
* Multi-account deployment compatibility
* Reusable Terraform module design

---

## Resources Created

| Resource     | Purpose                 |
| ------------ | ----------------------- |
| aws_instance | Creates an EC2 instance |

---

## Input Variables

| Variable          | Description                                       | Required | Default                          |
| ----------------- | ------------------------------------------------- | -------- | -------------------------------- |
| instance_type     | EC2 instance type                                 | Yes      | N/A                              |
| ami_id            | AMI ID used to launch the instance                | Yes      | N/A                              |
| ami_ssm_parameter | SSM Parameter path containing latest approved AMI | No       | `/platform/amis/frontend/latest` |
| environment       | Deployment environment                            | Yes      | N/A                              |
| name              | Resource name and tag prefix                      | Yes      | N/A                              |
| managed_by        | Tool used to provision resources                  | No       | `terraform-code`                 |

---

## Environment Validation

Only the following environments are supported:

```text
dev
staging
prod
```

Terraform validation prevents invalid values from being deployed.

Example:

```hcl
environment = "prod"
```

---

## Standard Tags

The module automatically applies consistent resource tags.

Example:

```text
Name        = frontend-app-prod
Environment = prod
ManagedBy   = terraform-code
```

---

## Example Usage

```hcl
module "frontend_instance" {
  source = "../modules/ec2-instance"

  name          = "frontend-app"
  environment   = "prod"
  instance_type = "t3.micro"

  ami_id = data.aws_ssm_parameter.frontend_ami.value
}
```

---

## Centralized AMI Management

This module is designed to work with a central Platform Account that publishes approved AMIs to AWS Systems Manager Parameter Store.

Example Parameter:

```text
/platform/amis/frontend/latest
```

Application accounts retrieve the latest approved AMI and pass it into this module during deployment.

---

## Deployment Flow

```text
Platform Account
        │
        ▼
SSM Parameter Store
(/platform/amis/frontend/latest)
        │
        ▼
Application Account
        │
        ▼
Terraform Module
        │
        ▼
EC2 Instance Deployment
```

---

## Use Cases

* Golden AMI deployments
* Multi-account AWS environments
* Infrastructure standardization
* Automated patch management
* Environment-specific deployments

---

## Author

Pushpak Badadale

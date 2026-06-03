<!-- BEGIN_TF_DOCS -->
# Vulnerability & Patch Management (VPM) Automation Foundation

This repository contains the foundational configurations and architectural answers required to eliminate manual, reactive patching of cloud infrastructure by implementing a 30-day immutable patching cycle using Terraform.

## Repository Structure

```text
├── modules/
│   └── ec2-instance/     # Task 1: Terraform Module: Managed EC2 Instance
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── drift-detection/      # Task 2: Simulated Drift Detection Logic
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
└── ANSWERS.md            # Task 3: Written Response (Design Questions)
└── README.md 
```

---

## Core Components Summary

### 1. Reusable EC2 Module (`/modules/ec2-instance`)
Standardized deployment module engineered for internal application teams. 
* Enforces structural isolation across standard `.tf` files.
* Includes input validation to restrict deployments exclusively to `dev`, `staging`, or `prod` environments.
* Programmatically applies mandatory compliance tags (`Name`, `Environment`, `ManagedBy`) without hardcoding values.

### 2. Drift Detection Engine (`/drift-detection`)
No infrastructure configuration designed to act as an automated logic gate in CI/CD pipelines. It consumes the actively running image ID and evaluates it against the latest approved AMI in the registry, with a native boolean flag (`drift_detected`) and a human readable string (`drift_status`) to feed downstream automations.

### 3. Compliance Guardrail Designs (`ANSWERS.md`)
Architectural summary detailing how the team can programmatically enforce the 30 day compliance boundary using data sources, policy as code frameworks like HashiCorp Sentinel inside our workflows before infrastructure provisioning.

---

## Implementation Assumptions

During implementation, the following architectural assumptions were made:

1. **Provider management**: The `ec2-instance` module intentionally leaves out provider-specific configuration blocks. It assumes that the root orchestrating repository will define the AWS provider region, credentials, and backend state configurations globally before calling this module.
2. **Simulated State for Testing**: The input variables provided in `/drift-detection/terraform.tfvars` leverage mock AMI IDs. This allows the drift evaluation logic to be tested safely in local environments.
3. **AWS Components**: To keep the module focused purely on the EC2 instance logic, other settings are not defined. Default values for VPC, Subnets, etc., are used. Also, AWS credentials are not explicitly configured in this setup assuming authentication is already in place.

---

## Submission Details

* **Submitted By:** Pushpak Badadale
* **Submission Date:** 2026-06-03
* **Position:** Platform Engineer

<!-- END_TF_DOCS -->

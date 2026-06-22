# Remote Backend Terraform Module

## Overview

This module provisions infrastructure required for Terraform remote state management.

It enables secure and centralized Terraform state storage for teams and automation pipelines.

---

## Features

* S3 backend creation
* Terraform state storage
* State versioning
* State locking support
* Team collaboration enablement

---

## Resources Created

| Resource                   | Purpose                    |
| -------------------------- | -------------------------- |
| S3 Bucket                  | Terraform state storage    |
| Bucket Versioning          | State history retention    |
| Optional Locking Mechanism | Prevent concurrent updates |

---

## Why Remote State?

Remote state provides:

* Shared infrastructure visibility
* Team collaboration
* State durability
* Automated CI/CD integration
* Protection against local state loss

---

## Example Usage

```hcl
module "remote_backend" {
  source = "../modules/remote-backend"

  bucket_name = "vpm-platform-tfstate-prod"
}
```

---

## Backend Configuration Example

```hcl
terraform {
  backend "s3" {
    bucket = "vpm-platform-tfstate-prod"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}
```

---

## State Management Workflow

```text
Terraform Apply
       │
       ▼
Remote State Stored
       │
       ▼
Version History Maintained
       │
       ▼
Team Access Enabled
```

---

## Benefits

* Centralized state management
* Improved reliability
* Better collaboration
* CI/CD compatibility
* Disaster recovery support

---

## Recommended Usage

Use a separate backend for:

* Platform Account
* Application Account 1
* Application Account 2

This ensures state isolation across environments.

---

## Author
Pushpak Badadale

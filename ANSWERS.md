<!-- BEGIN_TF_DOCS -->
# Task 3: Written Response (Design Questions)

## Question 1: The platform team wants to enforce that no EC2 instance can be deployed using an AMI older than 30 days. Where in the Terraform workflow would you implement this check, and what tooling would you use? Describe your approach in 2–3 sentences.

I would implement this check directly inside the CI/CD pipeline after the terraform plan phase using a policy as a code tool like HashiCorp Sentinel or OPA. To feed this tool data, Terraform can retrieve the AMI metadata using an AWS data source, allowing us to use native Terraform preconditions to validate the creation date. If the AMI is older than 30 days, either the precondition or the pre-apply pipeline hook will fail, safely blocking the non-compliant deployment.

## Question 2: A developer on an application team tells you they've hardcoded an AMI ID directly into their Terraform module instead of referencing the platform team's approved channel. What's the risk, and how would you address it both technically and through process?

Using a hardcoded AMI could lead to potential vulnerabilities in the system as it would not have the latest security patches applied to it. Technically, I would configure our CI/CD pipeline to scan the code for hardcoded string IDs and mandate that teams pull approved AMIs only using a centralized data source. From process and cultural perspective, I would document this workflow clearly in the documentation and make it part of the pull request review checklist where any exceptions would require approval from the platform team before merging.

## Question 3: You are asked to design a CI/CD pipeline step that automatically triggers a terraform apply when a new AMI version is promoted to the production channel. What are the risks of full automation here, and what guardrails would you put in place?

Full automation could roll out a faulty AMI, impacting multiple systems before the issue is detected. To mitigate this, I would enforce strict staging guardrails, promoting the AMI sequentially through dev, staging and then prod while running automated sanity tests at each gate. Further, instead of a full immediate rollout, I would implement a canary deployment strategy to update instances incrementally. For prod, I would keep manual approval step before final apply to avoid unplanned system downtime and also maintain rollback mechanism so that the previous AMI can be restored quickly if issues are detected.

<!-- END_TF_DOCS -->

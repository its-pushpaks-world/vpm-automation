<!-- BEGIN_TF_DOCS -->
# Task 1 — Terraform module for EC2 Instance

This reusable module creates an AWS EC2 instance with consistent resource tagging and environment validation.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID for the EC2 instance | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment to create the EC2 instance (dev/staging/prod) | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type (e.g. t3.medium) | `string` | n/a | yes |
| <a name="input_managed_by"></a> [managed\_by](#input\_managed\_by) | Tool used to create the infrastructure object | `string` | `"terraform-code"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of EC2 instance for resource naming and tags | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | EC2 instance id |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | EC2 instance private IP address |

## Example Usage

```hcl
module "tf_ec2_instance" {
  source = "./modules/ec2-instance"

  name = "frontend-instance"
  environment = "staging"
  instance_type = "t3.medium"
  ami_id = "ami-XXXXXXXXXXXXXXXXX"
}
<!-- END_TF_DOCS -->
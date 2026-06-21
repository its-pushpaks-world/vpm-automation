# Input variables for Terraform managed AWS EC2 instance

variable "instance_type" {
  type        = string
  description = "EC2 instance type (e.g. t3.medium)"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "ami_ssm_parameter" {
  type        = string
  description = "The SSM Parameter path in the central platform account"
  default     = "/platform/amis/frontend/latest"
}

variable "environment" {
  type        = string
  description = "Environment to create the EC2 instance (dev/staging/prod)"

  # This validation block ensures only dev/staging/prod is accepted as an input
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Wrong environment selected. Please select one out of these options: dev/staging/prod"
  }
}

variable "name" {
  type        = string
  description = "Name of EC2 instance for resource naming and tags"
}

variable "managed_by" {
  type        = string
  description = "Tool used to create the infrastructure object"
  default     = "terraform-code"
}

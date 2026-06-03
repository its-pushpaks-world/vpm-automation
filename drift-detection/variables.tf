# Variable declaration

variable "current_ami_id" {
  type        = string
  description = "AMI ID on the running AWS EC2 instance"
}

variable "approved_ami_id" {
  type        = string
  description = "Approved AMI ID from the registry"
}

# Resource block to created AWS EC2 instance via Terraform

resource "aws_instance" "ec2-tf" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = "${var.name}-${var.environment}"
    Environment = var.environment
    ManagedBy   = var.managed_by
  }
}

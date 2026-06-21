terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Removed configuration_aliases because this module no longer needs cross-account access!
    }
  }
}

# --- 1. Auto-Discover Default Networking ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# --- 2. Infrastructure Creation ---
resource "aws_launch_template" "ec2_lt" {
  name_prefix   = "${var.name}-lt-"
  
  # HERE IS WHERE AMI_ID IS USED! 
  # It takes the string passed from app-account/main.tf natively.
  image_id      = var.ami_id 
  
  instance_type = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.default.id]

  tags = {
    Name        = "${var.name}-${var.environment}"
    Environment = var.environment
    ManagedBy   = var.managed_by
  }
}

resource "aws_autoscaling_group" "ec2_asg" {
  name                = "${var.name}-asg"
  vpc_zone_identifier = data.aws_subnets.default.ids
  desired_capacity    = 1
  max_size            = 1
  min_size            = 0

  launch_template {
    id      = aws_launch_template.ec2_lt.id
    version = "$Latest"
  }
}

# --- 3. Business Hour Schedules ---
resource "aws_autoscaling_schedule" "scale_down" {
  scheduled_action_name  = "scale-down-nightly"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "0 18 * * *" 
  autoscaling_group_name = aws_autoscaling_group.ec2_asg.name
}

resource "aws_autoscaling_schedule" "scale_up" {
  scheduled_action_name  = "scale-up-morning"
  min_size               = 0
  max_size               = 1
  desired_capacity       = 1
  recurrence             = "0 8 * * *" 
  autoscaling_group_name = aws_autoscaling_group.ec2_asg.name
}

data "aws_instances" "asg_instances" {
  instance_tags = {
    "aws:autoscaling:groupName" = aws_autoscaling_group.ec2_asg.name
  }
  instance_state_names = ["running"]
}

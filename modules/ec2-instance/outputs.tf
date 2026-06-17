# Output declaration

output "instance_ids" {
  value       = data.aws_instances.asg_instances.ids
  description = "List of EC2 instance IDs currently running in the ASG"
}

output "private_ips" {
  value       = data.aws_instances.asg_instances.private_ips
  description = "List of private IP addresses for the instances currently running in the ASG"
}

output "asg_name" {
  value       = aws_autoscaling_group.ec2_asg.name
  description = "The name of the Auto Scaling Group"
}

output "launch_template_latest_version" {
  value       = aws_launch_template.ec2_lt.latest_version
  description = "The latest generated version of the Launch Template"
}

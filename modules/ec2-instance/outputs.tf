# Output declaration

output "instance_id" {
  value       = aws_instance.ec2-tf.id
  description = "EC2 instance id"
}

output "private_ip" {
  value       = aws_instance.ec2-tf.private_ip
  description = "EC2 instance private IP address"
}

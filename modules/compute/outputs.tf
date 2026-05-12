output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "security_group_id" {
  description = "ID of the instance security group"
  value       = aws_security_group.instance.id
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.main.private_ip
}

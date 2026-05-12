output "instance_role_arn" {
  description = "ARN of the instance IAM role"
  value       = aws_iam_role.instance.arn
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = aws_iam_instance_profile.instance.name
}

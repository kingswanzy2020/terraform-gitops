output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.compute.instance_id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = module.compute.private_ip
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.storage.bucket_id
}

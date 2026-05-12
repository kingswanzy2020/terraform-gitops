variable "project_name" {
  description = "Name of the project for resource tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket the instance can access"
  type        = string
}

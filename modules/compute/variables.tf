variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet to launch the instance in"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_profile_name" {
  description = "Name of the IAM instance profile"
  type        = string
}

variable "project_name" {
  description = "Name of the project for resource tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

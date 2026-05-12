variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

  # Validates that the value is a properly formatted CIDR block
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "project_name" {
  description = "Name of the project for resource tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  # Only allow known environment values
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

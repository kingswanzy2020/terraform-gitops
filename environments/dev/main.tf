terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Store state remotely in the S3 bucket you created in Step 1
  backend "s3" {
    bucket         = "fap-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}

# Configure the AWS provider with default tags applied to every resource
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Networking module creates VPC, subnets, and route tables
module "networking" {
  source = "../../modules/networking"

  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment
}

# Storage module creates an encrypted, versioned S3 bucket
module "storage" {
  source = "../../modules/storage"

  project_name = var.project_name
  environment  = var.environment
}

# IAM module creates the instance role with least-privilege S3 and CloudWatch access
module "iam" {
  source = "../../modules/iam"

  project_name  = var.project_name
  environment   = var.environment
  s3_bucket_arn = module.storage.bucket_arn
}

# Compute module launches the EC2 instance in the private subnet
module "compute" {
  source = "../../modules/compute"

  vpc_id                = module.networking.vpc_id
  subnet_id             = module.networking.private_subnet_ids[0]
  instance_type         = var.instance_type
  instance_profile_name = module.iam.instance_profile_name
  project_name          = var.project_name
  environment           = var.environment
}

module "database" {
  source = "../../modules/database"

  vpc_id                     = module.networking.vpc_id
  private_subnet_ids         = module.networking.private_subnet_ids
  allowed_security_group_ids = [module.compute.security_group_id]
  project_name               = var.project_name
  environment                = var.environment
}

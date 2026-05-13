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
}

# Generate a secure 16-character password for the database
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store the generated password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name_prefix = "${var.project_name}-${var.environment}-db-password-"
  description = "RDS PostgreSQL master password"

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-password"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.db_password.result
    engine   = "postgresql"
    port     = 5432
  })
}

# Place the database in the private subnets
resource "aws_db_subnet_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-"
  description = "Subnet group for RDS PostgreSQL"
  subnet_ids  = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Only allow PostgreSQL traffic from the EC2 instance
resource "aws_security_group" "database" {
  name_prefix = "${var.project_name}-${var.environment}-db-"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
    description     = "Allow PostgreSQL from application instances"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# The PostgreSQL RDS instance (free tier eligible)
resource "aws_db_instance" "main" {
  identifier_prefix      = "${var.project_name}-${var.environment}-"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "appdb"
  username               = "dbadmin"
  password               = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  skip_final_snapshot    = true
  storage_encrypted      = true
  multi_az               = false
  publicly_accessible    = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-db"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

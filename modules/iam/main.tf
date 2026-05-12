terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name_prefix        = "${var.project_name}-${var.environment}-instance-"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-instance-role"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

data "aws_iam_policy_document" "instance_permissions" {
  statement {
    sid = "AllowS3Access"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*",
    ]
  }

  statement {
    sid = "AllowCloudWatchLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "instance" {
  name_prefix = "${var.project_name}-${var.environment}-"
  role        = aws_iam_role.instance.id
  policy      = data.aws_iam_policy_document.instance_permissions.json
}

resource "aws_iam_instance_profile" "instance" {
  name_prefix = "${var.project_name}-${var.environment}-"
  role        = aws_iam_role.instance.name
}

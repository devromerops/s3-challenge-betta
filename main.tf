terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"  # Ajusta la versión según tus necesidades
    }
  }
}

provider "aws" {
  region = var.primary_region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}

resource "aws_iam_role" "replication_role" {
  name = "replication_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "replication_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = "s3:ReplicateObject"
          Resource = "*"
        }
      ]
    })
  }
}

module "s3_buckets" {
  source = "./modules/s3_buckets"
  for_each = var.bucket_names

  providers = {
    aws = aws
    aws.secondary = aws.secondary
  }

  bucket_names       = each.value
  enable_versioning  = true
  enable_replication = true
  replication_role   = aws_iam_role.replication_role.arn
  secondary_region   = var.secondary_region
  lifecycle_rules    = lookup(var.lifecycle_rules, each.key, [])
  bucket_websites    = lookup(var.bucket_websites, each.key, null)
}

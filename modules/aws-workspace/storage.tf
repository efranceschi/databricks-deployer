### Local Variables
locals {
  # Storage names
  final_storage_configuration_name = coalesce(var.storage_configuration_name, "${var.prefix}-storage")
  final_root_bucket_name           = coalesce(var.root_bucket_name, "${var.prefix}-root-storage")
}

### S3 Root Storage Bucket
# Create S3 bucket for Databricks workspace root storage (DBFS)
# This bucket stores workspace-level data including notebooks, libraries, and temporary files
# Reference: https://docs.databricks.com/aws/en/admin/account-settings-e2/storage
resource "aws_s3_bucket" "root_storage_bucket" {
  count  = var.create_root_bucket ? 1 : 0
  bucket = local.final_root_bucket_name
  tags   = var.tags
}

# Configure S3 bucket versioning (disabled for cost optimization)
resource "aws_s3_bucket_versioning" "root_versioning" {
  count  = var.create_root_bucket ? 1 : 0
  bucket = aws_s3_bucket.root_storage_bucket[0].id
  versioning_configuration {
    status = "Disabled"
  }
}

# Configure S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "root_encryption" {
  count  = var.create_root_bucket ? 1 : 0
  bucket = aws_s3_bucket.root_storage_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "root_bucket_pab" {
  count  = var.create_root_bucket ? 1 : 0
  bucket = aws_s3_bucket.root_storage_bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket policy to restrict access to Databricks cross-account role
resource "aws_s3_bucket_policy" "root_bucket_policy" {
  count      = var.create_root_bucket ? 1 : 0
  bucket     = aws_s3_bucket.root_storage_bucket[0].id
  depends_on = [aws_s3_bucket_public_access_block.root_bucket_pab]

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "GrantDatabricksAccess"
    Statement = [
      {
        Sid    = "AllowDatabricksAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::414351767826:root"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
        ]
        Resource = [
          aws_s3_bucket.root_storage_bucket[0].arn,
          "${aws_s3_bucket.root_storage_bucket[0].arn}/*"
        ]
        Condition = {
          "StringEquals" : {
            "aws:PrincipalTag/DatabricksAccountId" : [var.databricks_account_id]
          }
        }
      }
    ]
  })
}

# Data source for existing S3 bucket (when create_root_bucket = false)
data "aws_s3_bucket" "existing_root_bucket" {
  count  = var.create_root_bucket ? 0 : 1
  bucket = var.root_bucket_name
}

### Databricks Storage Configuration
# Register the S3 bucket with Databricks for workspace root storage
# Reference: https://docs.databricks.com/dev-tools/api/latest/account.html#operation/create-storage-configuration
resource "databricks_mws_storage_configurations" "this" {
  account_id                 = var.databricks_account_id
  storage_configuration_name = local.final_storage_configuration_name
  bucket_name                = var.create_root_bucket ? aws_s3_bucket.root_storage_bucket[0].bucket : data.aws_s3_bucket.existing_root_bucket[0].bucket
  depends_on                 = [aws_s3_bucket_policy.root_bucket_policy]
}

output "workspace_url" {
  description = "URL of the Databricks workspace"
  value       = databricks_mws_workspaces.databricks_workspace.workspace_url
}

output "workspace_id" {
  description = "ID of the Databricks workspace"
  value       = databricks_mws_workspaces.databricks_workspace.workspace_id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = var.create_vpc ? aws_vpc.databricks_vpc[0].id : data.aws_vpc.existing_vpc[0].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = var.create_vpc ? aws_subnet.private[*].id : data.aws_subnet.existing_private[*].id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = var.create_vpc ? aws_subnet.public[*].id : []
}

output "service_subnet_ids" {
  description = "IDs of the service subnets (used for VPC endpoints)"
  value       = var.create_vpc ? aws_subnet.service[*].id : data.aws_subnet.existing_service[*].id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = var.create_vpc ? aws_security_group.databricks_sg[0].id : data.aws_security_group.existing_sg[0].id
}

output "role_arn" {
  description = "ARN of the IAM role used for Databricks deployment"
  value       = local.final_role_arn
}

# Storage Outputs
output "storage_configuration_id" {
  description = "ID of the Databricks storage configuration"
  value       = databricks_mws_storage_configurations.this.storage_configuration_id
}

output "root_bucket_name" {
  description = "Name of the S3 bucket used for Databricks root storage"
  value       = var.create_root_bucket ? aws_s3_bucket.root_storage_bucket[0].bucket : data.aws_s3_bucket.existing_root_bucket[0].bucket
}

output "root_bucket_arn" {
  description = "ARN of the S3 bucket used for Databricks root storage"
  value       = var.create_root_bucket ? aws_s3_bucket.root_storage_bucket[0].arn : data.aws_s3_bucket.existing_root_bucket[0].arn
}
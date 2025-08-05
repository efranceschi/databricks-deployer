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

output "security_group_id" {
  description = "ID of the security group"
  value       = var.create_vpc ? aws_security_group.databricks_sg[0].id : data.aws_security_group.existing_sg[0].id
}
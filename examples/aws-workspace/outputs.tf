output "workspace_url" {
  value       = module.aws_workspace.workspace_url
  description = "The URL of the Databricks workspace"
}

output "workspace_id" {
  value       = module.aws_workspace.workspace_id
  description = "The ID of the Databricks workspace"
}

output "vpc_id" {
  value       = module.aws_workspace.vpc_id
  description = "The ID of the VPC"
}

output "private_subnet_ids" {
  value       = module.aws_workspace.private_subnet_ids
  description = "The IDs of the private subnets"
}

output "public_subnet_ids" {
  value       = module.aws_workspace.public_subnet_ids
  description = "The IDs of the public subnets"
}

output "security_group_id" {
  value       = module.aws_workspace.security_group_id
  description = "The ID of the security group"
}
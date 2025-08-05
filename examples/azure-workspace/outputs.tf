output "databricks_workspace_id" {
  value       = module.azure_workspace.databricks_workspace_id
  description = "The ID of the Databricks workspace in the Databricks account"
}

output "databricks_workspace_url" {
  value       = module.azure_workspace.databricks_workspace_url
  description = "The URL of the Databricks workspace"
}

output "azure_databricks_workspace_id" {
  value       = module.azure_workspace.azure_databricks_workspace_id
  description = "The ID of the Azure Databricks workspace"
}

output "azure_databricks_workspace_url" {
  value       = module.azure_workspace.azure_databricks_workspace_url
  description = "The URL of the Azure Databricks workspace"
}

output "azure_managed_resource_group_name" {
  value       = module.azure_workspace.azure_managed_resource_group_name
  description = "The name of the managed resource group for the Azure Databricks workspace"
}

output "databricks_network_id" {
  value       = module.azure_workspace.databricks_network_id
  description = "The ID of the Databricks network configuration"
}

output "databricks_private_access_settings_id" {
  value       = module.azure_workspace.databricks_private_access_settings_id
  description = "The ID of the Databricks private access settings"
}

output "azure_vnet_id" {
  value       = module.azure_workspace.azure_vnet_id
  description = "The ID of the Azure Virtual Network"
}

output "azure_vnet_name" {
  value       = module.azure_workspace.azure_vnet_name
  description = "The name of the Azure Virtual Network"
}

output "azure_subnet_public_id" {
  value       = module.azure_workspace.azure_subnet_public_id
  description = "The ID of the public subnet"
}

output "azure_subnet_private_id" {
  value       = module.azure_workspace.azure_subnet_private_id
  description = "The ID of the private subnet"
}

output "azure_private_endpoint_id" {
  value       = module.azure_workspace.azure_private_endpoint_id
  description = "The ID of the Azure Private Endpoint (if enabled)"
}
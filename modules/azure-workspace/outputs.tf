### Workspace Outputs
# output "databricks_workspace_id" {
#   description = "The ID of the Databricks workspace"
#   value       = azurerm_databricks_workspace.databricks_workspace.workspace_id
# }

# output "databricks_workspace_url" {
#   description = "The URL of the Databricks workspace"
#   value       = azurerm_databricks_workspace.databricks_workspace.workspace_url
# }

# output "azure_databricks_workspace_id" {
#   description = "The ID of the Azure Databricks workspace"
#   value       = azurerm_databricks_workspace.databricks_workspace.id
# }

# output "azure_databricks_workspace_url" {
#   description = "The URL of the Azure Databricks workspace"
#   value       = azurerm_databricks_workspace.databricks_workspace.workspace_url
# }

# output "azure_managed_resource_group_name" {
#   description = "The name of the managed resource group for the Azure Databricks workspace"
#   value       = azurerm_databricks_workspace.databricks_workspace.managed_resource_group_name
# }

output "azure_resource_group_name" {
  description = "The name of the resource group used for the Databricks workspace"
  value       = local.resource_group_name
}

# Note: databricks_network_id output removed as databricks_mws_networks is not used for Azure

output "databricks_private_access_settings_id" {
  description = "The ID of the Databricks private access settings"
  value       = var.manage_private_access_settings ? databricks_mws_private_access_settings.private_access_setting[0].private_access_settings_id : null
}

### VNet Outputs
output "azure_vnet_id" {
  description = "The ID of the VNet"
  value       = var.create_vnet ? azurerm_virtual_network.databricks_vnet[0].id : data.azurerm_virtual_network.existing_vnet[0].id
}

output "azure_vnet_name" {
  description = "The name of the VNet"
  value       = var.create_vnet ? azurerm_virtual_network.databricks_vnet[0].name : data.azurerm_virtual_network.existing_vnet[0].name
}

### Subnet Outputs
output "azure_subnet_public_id" {
  description = "The ID of the public subnet"
  value       = var.create_vnet ? azurerm_subnet.public[0].id : data.azurerm_subnet.existing_public[0].id
}

output "azure_subnet_private_id" {
  description = "The ID of the private subnet"
  value       = var.create_vnet ? azurerm_subnet.private[0].id : data.azurerm_subnet.existing_private[0].id
}

### Private Link Outputs
# output "azure_private_endpoint_id" {
#   description = "The ID of the private endpoint"
#   value       = var.enable_private_link ? azurerm_private_endpoint.databricks_endpoint[0].id : null
# }
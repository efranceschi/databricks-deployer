### Local Variables
locals {
  # Names
  final_workspace_name                = coalesce(var.workspace_name, "${var.prefix}")
  final_managed_resource_group_name   = coalesce(var.azure_managed_resource_group_name, "${var.prefix}-databricks-managed-rg")
}

### Workspace
resource "azurerm_databricks_workspace" "databricks_workspace" {
  name                        = local.final_workspace_name
  resource_group_name         = local.resource_group_name
  location                    = var.azure_location
  sku                         = var.pricing_tier
  managed_resource_group_name = local.final_managed_resource_group_name
  tags                        = var.tags

  custom_parameters {
    no_public_ip        = true
    virtual_network_id  = var.create_vnet ? azurerm_virtual_network.databricks_vnet[0].id : data.azurerm_virtual_network.existing_vnet[0].id
    public_subnet_name  = var.create_vnet ? azurerm_subnet.public[0].name : data.azurerm_subnet.existing_public[0].name
    private_subnet_name = var.create_vnet ? azurerm_subnet.private[0].name : data.azurerm_subnet.existing_private[0].name
    public_subnet_network_security_group_association_id  = var.create_vnet ? azurerm_subnet_network_security_group_association.public_nsg[0].id : null
    private_subnet_network_security_group_association_id = var.create_vnet ? azurerm_subnet_network_security_group_association.private_nsg[0].id : null
  }
}

# Note: For Azure deployments, we use azurerm_databricks_workspace resource above
# The databricks_mws_workspaces resource is only for AWS or GCP deployments
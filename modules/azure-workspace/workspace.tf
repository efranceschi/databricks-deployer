### Local Variables
locals {
  # Names
  final_workspace_name                = coalesce(var.workspace_name, "${var.prefix}")
  final_managed_resource_group_name   = coalesce(var.azure_managed_resource_group_name, "${var.prefix}-managed-rg")
}

### Workspace
resource "azurerm_databricks_workspace" "databricks_workspace" {
  name                        = local.final_workspace_name
  resource_group_name         = local.resource_group_name
  location                    = var.region
  sku                         = lower(var.pricing_tier)
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

# Look up metastore by name to get the metastore ID
data "databricks_metastore" "this" {
  count = var.metastore != null ? 1 : 0
  name  = var.metastore
}

### Metastore Assignment
# Assign Unity Catalog metastore to the workspace when metastore variable is provided
# Reference: https://docs.databricks.com/data-governance/unity-catalog/index.html
resource "databricks_metastore_assignment" "this" {
  count        = var.metastore != null ? 1 : 0
  workspace_id = databricks_mws_workspaces.databricks_workspace.workspace_id
  metastore_id = data.databricks_metastore.this[0].id
}

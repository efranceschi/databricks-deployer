### Local Variables
locals {
  # Names
  final_network_config_name         = coalesce(var.network_config_name, "${var.prefix}-network")
  final_private_access_setting_name = coalesce(var.private_access_setting_name, "${var.prefix}-pas")
  final_azure_private_endpoint_name = coalesce(var.azure_private_endpoint_name, "${var.prefix}-private-endpoint")
}

### Private Link Resources
resource "azurerm_private_endpoint" "databricks_endpoint" {
  count               = var.enable_private_link ? 1 : 0
  name                = local.final_azure_private_endpoint_name
  resource_group_name = local.resource_group_name
  location            = var.region
  subnet_id           = var.create_vnet ? azurerm_subnet.private[0].id : data.azurerm_subnet.existing_private[0].id
  tags                = var.tags

  private_service_connection {
    name                           = "${local.final_azure_private_endpoint_name}-connection"
    private_connection_resource_id = azurerm_databricks_workspace.databricks_workspace.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  private_dns_zone_group {
    name                 = "${local.final_azure_private_endpoint_name}-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.databricks_dns[0].id]
  }
}

resource "azurerm_private_dns_zone" "databricks_dns" {
  count               = var.enable_private_link ? 1 : 0
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = local.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "databricks_dns_link" {
  count                 = var.enable_private_link ? 1 : 0
  name                  = "${local.final_azure_private_endpoint_name}-dns-link"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.databricks_dns[0].name
  virtual_network_id    = var.create_vnet ? azurerm_virtual_network.databricks_vnet[0].id : data.azurerm_virtual_network.existing_vnet[0].id
  tags                  = var.tags
}

# Note: databricks_mws_networks is not used for Azure deployments
# Network configuration for Azure is handled through azurerm_databricks_workspace custom_parameters

### Databricks Private Access Setting
resource "databricks_mws_private_access_settings" "private_access_setting" {
  count                        = var.manage_private_access_settings ? 1 : 0
  private_access_settings_name = local.final_private_access_setting_name
  region                       = var.region
  public_access_enabled        = true
  private_access_level         = var.enable_private_link ? "ACCOUNT" : "ENDPOINT"
}
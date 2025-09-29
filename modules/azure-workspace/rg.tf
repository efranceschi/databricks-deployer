### Resource Group
locals {
  final_azure_resource_group_name = coalesce(var.azure_resource_group, "${var.prefix}-rg")
}

resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = local.final_azure_resource_group_name
  location = var.region
  tags     = var.tags
}

data "azurerm_resource_group" "existing" {
  count = var.create_resource_group ? 0 : 1
  name  = local.final_azure_resource_group_name
}

module "azure_workspace" {
  source = "../../modules/azure-workspace"

  # General
  prefix = var.prefix

  # Databricks
  databricks_account_id        = var.databricks_account_id
  databricks_client_id         = var.databricks_client_id
  databricks_client_secret     = var.databricks_client_secret
  workspace_name               = var.workspace_name
  network_config_name          = var.network_config_name
  private_access_setting_name  = var.private_access_setting_name
  pricing_tier                 = var.pricing_tier

  # Azure
  azure_subscription_id          = var.azure_subscription_id
  azure_resource_group           = var.azure_resource_group
  azure_location                 = var.azure_location
  azure_tenant_id                = var.azure_tenant_id
  azure_managed_resource_group_name = var.azure_managed_resource_group_name

  # Network Names
  azure_vnet_name          = var.azure_vnet_name
  create_vnet              = var.create_vnet
  azure_subnet_public_name = var.azure_subnet_public_name
  azure_subnet_private_name = var.azure_subnet_private_name
  azure_nsg_name           = var.azure_nsg_name
  azure_route_table_name   = var.azure_route_table_name
  azure_nat_gateway_name   = var.azure_nat_gateway_name

  # Network CIDRs
  azure_vnet_cidr          = var.azure_vnet_cidr
  azure_vnet_cidr_newbits  = var.azure_vnet_cidr_newbits
  azure_subnet_public_cidr = var.azure_subnet_public_cidr
  azure_subnet_private_cidr = var.azure_subnet_private_cidr

  # Private Link
  enable_private_link       = var.enable_private_link
  azure_private_endpoint_name = var.azure_private_endpoint_name

  # Tags
  tags = var.tags
}
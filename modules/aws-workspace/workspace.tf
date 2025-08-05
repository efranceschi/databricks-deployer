### Local Variables
locals {
  # Names
  final_workspace_name = coalesce(var.workspace_name, "${var.prefix}")
}

### Workspace
resource "databricks_mws_workspaces" "databricks_workspace" {
  account_id                 = var.databricks_account_id
  workspace_name             = local.final_workspace_name
  aws_region                 = var.aws_region
  network_id                 = databricks_mws_networks.databricks_network.network_id
  private_access_settings_id = databricks_mws_private_access_settings.private_access_setting.private_access_settings_id
  pricing_tier               = var.pricing_tier
  credentials_id             = databricks_mws_credentials.this.credentials_id
}

### Credentials
resource "databricks_mws_credentials" "this" {
  account_id       = var.databricks_account_id
  credentials_name = "${var.prefix}-credentials"
  role_arn         = var.aws_role_arn
}
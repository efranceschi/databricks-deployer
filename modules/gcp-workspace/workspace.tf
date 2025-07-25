### Local Variables
locals {
  # Names
  final_workspace_name = coalesce(var.workspace_name, "${var.prefix}")
}

### Workspace
resource "databricks_mws_workspaces" "databricks_workspace" {
  account_id                 = var.databricks_account_id
  workspace_name             = local.final_workspace_name
  location                   = var.google_region
  network_id                 = databricks_mws_networks.databricks_network.network_id
  private_access_settings_id = databricks_mws_private_access_settings.private_access_setting.private_access_settings_id
  pricing_tier               = var.pricing_tier
  cloud_resource_container {
    gcp {
      project_id = var.google_project
    }
  }
}

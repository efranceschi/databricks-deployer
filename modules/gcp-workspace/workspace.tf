### Local Variables
locals {
  # Names
  final_workspace_name = coalesce(var.workspace_name, "${var.prefix}")
}

### Workspace
resource "databricks_mws_workspaces" "databricks_workspace" {
  account_id                 = var.databricks_account_id
  workspace_name             = local.final_workspace_name
  location                   = var.region
  network_id                 = databricks_mws_networks.databricks_network.network_id
  private_access_settings_id = databricks_mws_private_access_settings.private_access_setting.private_access_settings_id
  pricing_tier               = var.pricing_tier
  cloud_resource_container {
    gcp {
      project_id = var.google_project
    }
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

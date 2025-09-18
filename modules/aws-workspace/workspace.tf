### Local Variables
locals {
  # Names
  final_workspace_name = coalesce(var.workspace_name, "${var.prefix}")
}

### Workspace
# Create Databricks workspace using Multi-Workspace API (MWS)
# Reference: https://docs.databricks.com/dev-tools/api/latest/account.html#operation/create-workspace
resource "databricks_mws_workspaces" "databricks_workspace" {
  account_id                 = var.databricks_account_id                                                                # Databricks account ID
  workspace_name             = local.final_workspace_name                                                               # Workspace display name
  deployment_name            = local.final_workspace_name                                                               # Workspace deployment name
  aws_region                 = var.region                                                                           # AWS region for deployment
  network_id                 = databricks_mws_networks.databricks_network.network_id                                    # Network configuration ID
  private_access_settings_id = databricks_mws_private_access_settings.private_access_setting.private_access_settings_id # Private access settings ID
  pricing_tier               = var.pricing_tier                                                                         # Databricks pricing tier (STANDARD, PREMIUM, ENTERPRISE)
  credentials_id             = databricks_mws_credentials.this.credentials_id                                           # Cross-account IAM role credentials ID
  storage_configuration_id   = databricks_mws_storage_configurations.this.storage_configuration_id                      # Storage configuration ID for root S3 bucket
}

### Metastore Data Source
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

# Reference: https://docs.databricks.com/administration-guide/account-settings/aws-accounts.html#step-2-create-a-cross-account-iam-role
resource "databricks_mws_credentials" "this" {
  credentials_name = "${var.prefix}-credentials" # Unique name for the credentials configuration
  role_arn         = local.final_role_arn        # ARN of the cross-account IAM role

  depends_on = [
    aws_iam_role.databricks_cross_account_role,
    aws_iam_role_policy.databricks_cross_account_policy,
    time_sleep.wait_for_iam_policy
  ]
}

# Add delay to ensure IAM policy propagation
resource "time_sleep" "wait_for_iam_policy" {
  create_duration = "30s"

  depends_on = [
    aws_iam_role_policy.databricks_cross_account_policy
  ]
}

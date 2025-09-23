### Workspace Outputs
output "workspace_id" {
  description = "The ID of the Databricks workspace"
  value       = databricks_mws_workspaces.databricks_workspace.workspace_id
}

output "workspace_url" {
  description = "The URL of the Databricks workspace"
  value       = databricks_mws_workspaces.databricks_workspace.workspace_url
}

output "network_id" {
  description = "The ID of the Databricks network configuration"
  value       = databricks_mws_networks.databricks_network.network_id
}

output "private_access_settings_id" {
  description = "The ID of the Databricks private access settings"
  value       = databricks_mws_private_access_settings.private_access_setting.private_access_settings_id
}

### VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.create_vpc ? google_compute_network.dbx_private_vpc[0].id : data.google_compute_network.existing_vpc[0].id
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = var.create_vpc ? google_compute_network.dbx_private_vpc[0].name : data.google_compute_network.existing_vpc[0].name
}

### Subnet Outputs
output "primary_subnet_id" {
  description = "The ID of the primary subnet"
  value       = google_compute_subnetwork.network-with-private-secondary-ip-ranges.id
}

output "pods_subnet_id" {
  description = "The ID of the pods subnet"
  value       = google_compute_subnetwork.backend_pods_subnetwork.id
}

output "services_subnet_id" {
  description = "The ID of the services subnet"
  value       = local.final_enable_dataplane_relay_psc || local.final_enable_rest_api_psc ? google_compute_subnetwork.backend_svc_subnetwork[0].id : null
}

### PSC Outputs
output "dataplane_relay_psc_endpoint_id" {
  description = "The ID of the dataplane relay PSC endpoint"
  value       = local.final_enable_dataplane_relay_psc ? google_compute_forwarding_rule.dataplane_relay_psc_ep[0].id : null
}

output "rest_api_psc_endpoint_id" {
  description = "The ID of the REST API PSC endpoint"
  value       = local.final_enable_rest_api_psc ? google_compute_forwarding_rule.rest_api_psc_ep[0].id : null
}
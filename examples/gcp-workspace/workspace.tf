module "databricks_gcp_workspace" {
  source = "../../modules/gcp-workspace"

  ### General
  prefix = var.prefix

  ### Databricks
  databricks_account_id       = var.databricks_account_id
  databricks_client_secret    = var.databricks_client_secret
  databricks_client_id        = var.databricks_client_id
  workspace_name              = var.workspace_name
  network_config_name         = var.network_config_name
  private_access_setting_name = var.private_access_setting_name
  pricing_tier                = var.pricing_tier

  ### Google
  google_project         = var.google_project
  google_region          = var.google_region
  google_service_account = var.google_service_account

  ### Network Names
  create_vpc              = var.create_vpc 
  google_vpc_name         = var.google_vpc_name
  google_subnet_name      = var.google_subnet_name
  google_subnet_pods_name = var.google_subnet_pods_name
  google_subnet_svc_name  = var.google_subnet_svc_name
  google_router_name      = var.google_router_name
  google_nat_name         = var.google_nat_name

  ### Network CIDRs
  google_vpc_cidr         = var.google_vpc_cidr
  google_vpc_cidr_newbits = var.google_vpc_cidr_newbits
  google_subnet_ip_cidr   = var.google_subnet_ip_cidr
  google_pods_ip_cidr     = var.google_pods_ip_cidr
  google_svc_ip_cidr      = var.google_svc_ip_cidr

  ### Private Connect
  enable_psc                               = var.enable_psc
  enable_dataplane_relay_psc               = var.enable_dataplane_relay_psc
  enable_rest_api_psc                      = var.enable_rest_api_psc
  google_dataplane_relay_endpoint_vpc_name = var.google_dataplane_relay_endpoint_vpc_name
  google_dataplane_relay_endpoint_psc_name = var.google_dataplane_relay_endpoint_psc_name
  google_dataplane_relay_endpoint_ip_name  = var.google_dataplane_relay_endpoint_ip_name
  google_rest_api_endpoint_vpc_name        = var.google_rest_api_endpoint_vpc_name
  google_rest_api_endpoint_psc_name        = var.google_rest_api_endpoint_psc_name
  google_rest_api_endpoint_ip_name         = var.google_rest_api_endpoint_ip_name
}

### Outputs

# Workspace Outputs
output "workspace_id" {
  description = "The ID of the Databricks workspace"
  value       = module.databricks_gcp_workspace.workspace_id
}

output "workspace_url" {
  description = "The URL of the Databricks workspace"
  value       = module.databricks_gcp_workspace.workspace_url
}

output "network_id" {
  description = "The ID of the Databricks network configuration"
  value       = module.databricks_gcp_workspace.network_id
}

output "private_access_settings_id" {
  description = "The ID of the Databricks private access settings"
  value       = module.databricks_gcp_workspace.private_access_settings_id
}

# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.databricks_gcp_workspace.vpc_id
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = module.databricks_gcp_workspace.vpc_name
}

# Subnet Outputs
output "primary_subnet_id" {
  description = "The ID of the primary subnet"
  value       = module.databricks_gcp_workspace.primary_subnet_id
}

output "pods_subnet_id" {
  description = "The ID of the pods subnet"
  value       = module.databricks_gcp_workspace.pods_subnet_id
}

output "services_subnet_id" {
  description = "The ID of the services subnet"
  value       = module.databricks_gcp_workspace.services_subnet_id
}

# PSC Outputs
output "dataplane_relay_psc_endpoint_id" {
  description = "The ID of the dataplane relay PSC endpoint"
  value       = module.databricks_gcp_workspace.dataplane_relay_psc_endpoint_id
}

output "rest_api_psc_endpoint_id" {
  description = "The ID of the REST API PSC endpoint"
  value       = module.databricks_gcp_workspace.rest_api_psc_endpoint_id
}

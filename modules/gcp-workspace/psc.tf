### Local Variables
locals {
  # Names
  final_network_config_name         = coalesce(var.network_config_name, "${var.prefix}-network")
  final_private_access_setting_name = coalesce(var.private_access_setting_name, "${var.prefix}-pas")

  # Endpoints
  final_google_dataplane_relay_endpoint_ip_name  = coalesce(var.google_dataplane_relay_endpoint_ip_name, "${var.prefix}-relay-ip")
  final_google_dataplane_relay_endpoint_psc_name = coalesce(var.google_dataplane_relay_endpoint_psc_name, "${var.prefix}-relay-psc")
  final_google_rest_api_endpoint_ip_name         = coalesce(var.google_rest_api_endpoint_ip_name, "${var.prefix}-wrk-ip")
  final_google_rest_api_endpoint_psc_name        = coalesce(var.google_rest_api_endpoint_psc_name, "${var.prefix}-wrk-psc")

  # Private Service Connect
  final_enable_rest_api_psc        = coalesce(var.enable_psc, var.enable_rest_api_psc, false)
  final_enable_dataplane_relay_psc = coalesce(var.enable_psc, var.enable_dataplane_relay_psc, false)

  # See https://docs.databricks.com/gcp/en/resources/ip-domain-region#private-service-connect-psc-attachment-uris-and-project-numbers
  scc_relay_by_region = {
    asia-northeast1         = "projects/prod-gcp-asia-northeast1/regions/asia-northeast1/serviceAttachments/ngrok-psc-endpoint"
    asia-south1             = "projects/prod-gcp-asia-south1/regions/asia-south1/serviceAttachments/ngrok-psc-endpoint"
    asia-southeast1         = "projects/prod-gcp-asia-southeast1/regions/asia-southeast1/serviceAttachments/ngrok-psc-endpoint"
    australia-southeast1    = "projects/prod-gcp-australia-southeast1/regions/australia-southeast1/serviceAttachments/ngrok-psc-endpoint"
    europe-west1            = "projects/prod-gcp-europe-west1/regions/europe-west1/serviceAttachments/ngrok-psc-endpoint"
    europe-west2            = "projects/prod-gcp-europe-west2/regions/europe-west2/serviceAttachments/ngrok-psc-endpoint"
    europe-west3            = "projects/prod-gcp-europe-west3/regions/europe-west3/serviceAttachments/ngrok-psc-endpoint"
    northamerica-northeast1 = "projects/prod-gcp-na-northeast1/regions/northamerica-northeast1/serviceAttachments/ngrok-psc-endpoint"
    us-central1             = "projects/prod-gcp-us-central1/regions/us-central1/serviceAttachments/ngrok-psc-endpoint"
    us-east1                = "projects/prod-gcp-us-east1/regions/us-east1/serviceAttachments/ngrok-psc-endpoint"
    us-east4                = "projects/prod-gcp-us-east4/regions/us-east4/serviceAttachments/ngrok-psc-endpoint"
    us-west1                = "projects/prod-gcp-us-west1/regions/us-west1/serviceAttachments/ngrok-psc-endpoint"
    us-west4                = "projects/prod-gcp-us-west4/regions/us-west4/serviceAttachments/ngrok-psc-endpoint"
  }
  final_google_relay_service_attachment = local.scc_relay_by_region[var.google_region]

  # See https://docs.databricks.com/gcp/en/resources/ip-domain-region#private-service-connect-psc-attachment-uris-and-project-numbers
  workspace_psc_by_region = {
    asia-northeast1         = "projects/general-prod-asianortheast1-01/regions/asia-northeast1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    asia-south1             = "projects/gen-prod-asias1-01/regions/asia-south1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    asia-southeast1         = "projects/general-prod-asiasoutheast1-01/regions/asia-southeast1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    australia-southeast1    = "projects/general-prod-ausoutheast1-01/regions/australia-southeast1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    europe-west1            = "projects/general-prod-europewest1-01/regions/europe-west1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    europe-west2            = "projects/general-prod-europewest2-01/regions/europe-west2/serviceAttachments/plproxy-psc-endpoint-all-ports"
    europe-west3            = "projects/general-prod-europewest3-01/regions/europe-west3/serviceAttachments/plproxy-psc-endpoint-all-ports"
    northamerica-northeast1 = "projects/general-prod-nanortheast1-01/regions/northamerica-northeast1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    us-central1             = "projects/gcp-prod-general/regions/us-central1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    us-east1                = "projects/general-prod-useast1-01/regions/us-east1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    us-east4                = "projects/general-prod-useast4-01/regions/us-east4/serviceAttachments/plproxy-psc-endpoint-all-ports"
    us-west1                = "projects/general-prod-uswest1-01/regions/us-west1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    us-west4                = "projects/general-prod-uswest4-01/regions/us-west4/serviceAttachments/plproxy-psc-endpoint-all-ports"
  }
  final_google_rest_api_service_attachment = local.workspace_psc_by_region[var.google_region]
}

### Create GCP Endpoints
resource "google_compute_address" "dataplane_relay_endpoint_ip_address" {
  count        = local.final_enable_dataplane_relay_psc ? 1 : 0
  name         = local.final_google_dataplane_relay_endpoint_ip_name
  project      = var.google_project
  region       = var.google_region
  subnetwork   = google_compute_subnetwork.backend_svc_subnetwork.id
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "dataplane_relay_psc_ep" {
  count      = local.final_enable_dataplane_relay_psc ? 1 : 0
  name       = local.final_google_dataplane_relay_endpoint_psc_name
  region     = var.google_region
  project    = var.google_project
  network    = google_compute_network.dbx_private_vpc.id
  ip_address = google_compute_address.dataplane_relay_endpoint_ip_address[0].id
  target     = local.final_google_relay_service_attachment
  # This field must be set to "" if the target is an URI of a service attachment. Default value is EXTERNAL
  load_balancing_scheme = ""
}

resource "google_compute_address" "rest_api_ip_address" {
  count        = local.final_enable_rest_api_psc ? 1 : 0
  name         = local.final_google_rest_api_endpoint_ip_name
  project      = var.google_project
  region       = var.google_region
  subnetwork   = google_compute_subnetwork.backend_svc_subnetwork.id
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "rest_api_psc_ep" {
  count      = local.final_enable_rest_api_psc ? 1 : 0
  name       = local.final_google_rest_api_endpoint_psc_name
  region     = var.google_region
  project    = var.google_project
  network    = google_compute_network.dbx_private_vpc.id
  ip_address = google_compute_address.rest_api_ip_address[0].id
  target     = local.final_google_rest_api_service_attachment
  #This field must be set to "" if the target is an URI of a service attachment. Default value is EXTERNAL
  load_balancing_scheme = ""
}

### Private Service Connect Endpoints
resource "databricks_mws_vpc_endpoint" "dataplane_relay" {
  count             = local.final_enable_dataplane_relay_psc ? 1 : 0
  account_id        = var.databricks_account_id
  vpc_endpoint_name = google_compute_forwarding_rule.dataplane_relay_psc_ep[0].name
  gcp_vpc_endpoint_info {
    project_id        = var.google_project
    psc_endpoint_name = google_compute_forwarding_rule.dataplane_relay_psc_ep[0].name
    endpoint_region   = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
  }
}

resource "databricks_mws_vpc_endpoint" "rest_api" {
  count             = local.final_enable_rest_api_psc ? 1 : 0
  account_id        = var.databricks_account_id
  vpc_endpoint_name = google_compute_forwarding_rule.rest_api_psc_ep[0].name
  gcp_vpc_endpoint_info {
    project_id        = var.google_project
    psc_endpoint_name = google_compute_forwarding_rule.rest_api_psc_ep[0].name
    endpoint_region   = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
  }
}

### Databricks Network
resource "databricks_mws_networks" "databricks_network" {
  account_id   = var.databricks_account_id
  network_name = local.final_network_config_name
  gcp_network_info {
    network_project_id = var.google_project
    vpc_id             = google_compute_network.dbx_private_vpc.name
    subnet_id          = google_compute_subnetwork.network-with-private-secondary-ip-ranges.name
    subnet_region      = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
  }
  vpc_endpoints {
    dataplane_relay = local.final_enable_dataplane_relay_psc ? [databricks_mws_vpc_endpoint.dataplane_relay[0].vpc_endpoint_id] : []
    rest_api        = local.final_enable_rest_api_psc ? [databricks_mws_vpc_endpoint.rest_api[0].vpc_endpoint_id] : []
  }
}

### Databricks Private Access Setting
resource "databricks_mws_private_access_settings" "private_access_setting" {
  private_access_settings_name = local.final_private_access_setting_name
  region                       = var.google_region
  public_access_enabled        = true
}

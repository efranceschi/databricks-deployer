### Local Variables
locals {
  # Names
  final_google_vpc_name         = coalesce(var.google_vpc_name, "${var.prefix}-vpc")
  final_google_subnet_name      = coalesce(var.google_subnet_name, "${var.prefix}-subnet")
  final_google_subnet_pods_name = coalesce(var.google_subnet_pods_name, "${var.prefix}-pods-subnet")
  final_google_subnet_svc_name  = coalesce(var.google_subnet_svc_name, "${var.prefix}-svc-subnet")
  final_google_router_name      = coalesce(var.google_router_name, "${var.prefix}-router")
  final_google_nat_name         = coalesce(var.google_nat_name, "${var.prefix}-nat")

  # CIDRs
  final_google_subnet_ip_cidr = coalesce(var.google_subnet_ip_cidr, cidrsubnet(var.google_vpc_cidr, var.google_vpc_cidr_newbits, 0))
  final_google_pods_ip_cidr   = coalesce(var.google_pods_ip_cidr, cidrsubnet(var.google_vpc_cidr, var.google_vpc_cidr_newbits, 1))
  final_google_svc_ip_cidr    = coalesce(var.google_svc_ip_cidr, cidrsubnet(var.google_vpc_cidr, var.google_vpc_cidr_newbits, 2))
}

### VPC
resource "google_compute_network" "dbx_private_vpc" {
  count                   = var.create_vpc ? 1 : 0
  project                 = var.google_project
  name                    = local.final_google_vpc_name
  auto_create_subnetworks = false
}

data "google_compute_network" "existing_vpc" {
  count                   = var.create_vpc ? 0 : 1
  project                 = var.google_project
  name                    = local.final_google_vpc_name
}

### Subnets
resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name                     = local.final_google_subnet_name
  ip_cidr_range            = local.final_google_subnet_ip_cidr
  region                   = var.google_region
  network                  = var.create_vpc ? google_compute_network.dbx_private_vpc[0].id : data.google_compute_network.existing_vpc[0].id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "backend_svc_subnetwork" {
  name                     = local.final_google_subnet_svc_name
  ip_cidr_range            = local.final_google_svc_ip_cidr
  region                   = var.google_region
  network                  = var.create_vpc ? google_compute_network.dbx_private_vpc[0].id : data.google_compute_network.existing_vpc[0].id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "backend_pods_subnetwork" {
  name                     = local.final_google_subnet_pods_name
  ip_cidr_range            = local.final_google_pods_ip_cidr
  region                   = var.google_region
  network                  = var.create_vpc ? google_compute_network.dbx_private_vpc[0].id : data.google_compute_network.existing_vpc[0].id
  private_ip_google_access = true
}

### Router
resource "google_compute_router" "router" {
  name    = local.final_google_router_name
  region  = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
  network = var.create_vpc ? google_compute_network.dbx_private_vpc[0].id : data.google_compute_network.existing_vpc[0].id
}

### NAT
# TODO: Add permission compute.addresses.deleteInternal
resource "google_compute_router_nat" "nat" {
  name                               = local.final_google_nat_name
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

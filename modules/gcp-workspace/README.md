# Databricks GCP Workspace Module

This Terraform module deploys a Databricks workspace in Google Cloud Platform (GCP) with the following components:

- GCP VPC Network (can use existing or create new)
- Subnets for Databricks workspace (primary, pods, and services)
- NAT Gateway for outbound connectivity
- Private Service Connect (PSC) endpoints for Databricks services (optional)
- Databricks workspace with network configuration

## Architecture

This module creates a Databricks workspace in GCP with the following architecture:

1. A VPC network (either newly created or existing)
2. Three subnets:
   - Primary subnet for Databricks nodes
   - Pods subnet for Kubernetes pods
   - Services subnet for Kubernetes services
3. Cloud Router and NAT Gateway for outbound connectivity
4. Optional Private Service Connect endpoints for:
   - Dataplane Relay service
   - REST API service
5. Databricks workspace connected to the network configuration

## Requirements

| Name | Version |
|------|--------|
| terraform | >= 1.0.0 |
| databricks | >= 1.0.0 |
| google | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|  
| databricks | >= 1.0.0 |
| google | >= 4.0.0 |

## Resources

| Name | Type |
|------|------|
| [databricks_mws_networks.databricks_network](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_networks) | resource |
| [databricks_mws_private_access_settings.private_access_setting](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_private_access_settings) | resource |
| [databricks_mws_vpc_endpoint.dataplane_relay](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint) | resource |
| [databricks_mws_vpc_endpoint.rest_api](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint) | resource |
| [databricks_mws_workspaces.databricks_workspace](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_workspaces) | resource |
| [google_compute_address.dataplane_relay_endpoint_ip_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.rest_api_ip_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_forwarding_rule.dataplane_relay_psc_ep](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_forwarding_rule.rest_api_psc_ep](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_network.dbx_private_vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.backend_pods_subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.backend_svc_subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.network-with-private-secondary-ip-ranges](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_network.existing_vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |

## Usage

```hcl
module "databricks_gcp_workspace" {
  source = "path/to/modules/gcp-workspace"

  # General
  prefix = "myproject"

  # Databricks
  databricks_account_id    = "12345678-1234-1234-1234-123456789012"
  databricks_client_id     = "12345678-1234-1234-1234-123456789012"
  databricks_client_secret = "your-client-secret"
  workspace_name           = "my-workspace"
  pricing_tier             = "PREMIUM"

  # Google
  google_project         = "my-gcp-project"
  region          = "us-central1"
  google_service_account = "sa-name@my-gcp-project.iam.gserviceaccount.com"

  # Network
  create_vpc = true
  google_vpc_cidr = "10.0.0.0/16"

  # Private Service Connect (optional)
  enable_psc = true
}
```

## Inputs

### General

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| prefix | Project prefix (used for naming resources) | `string` | n/a | yes |

### Databricks

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| databricks_account_id | Databricks Account ID | `string` | n/a | yes |
| databricks_client_id | Client ID for the service principal | `string` | n/a | yes |
| databricks_client_secret | Client Secret for the service principal | `string` | n/a | yes |
| workspace_name | The Workspace name | `string` | `null` | no |
| network_config_name | The network configuration name | `string` | `null` | no |
| private_access_setting_name | The private access setting name | `string` | `null` | no |
| pricing_tier | Pricing Tier | `string` | `"PREMIUM"` | no |

### Google

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| google_project | Google Project Name | `string` | n/a | yes |
| region | Google Region | `string` | n/a | yes |
| google_service_account | Email of the service account used for deployment | `string` | n/a | yes |

### Network Names

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_vpc | Terraform should create the VPC | `bool` | `true` | no |
| google_vpc_name | VPC name used for deployment | `string` | `null` | no |
| google_subnet_name | Subnet name used for deployment | `string` | `null` | no |
| google_subnet_pods_name | Subnet name used for pods deployment | `string` | `null` | no |
| google_subnet_svc_name | Subnet name used for services deployment | `string` | `null` | no |
| google_router_name | Name of the compute router to create | `string` | `null` | no |
| google_nat_name | Name of the NAT service in compute router | `string` | `null` | no |

### Network CIDRs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| google_vpc_cidr | IP Range for VPC | `string` | `"10.0.0.0/16"` | no |
| google_vpc_cidr_newbits | Number of new bits to automatically calculate the subnets mask | `number` | `8` | no |
| google_subnet_ip_cidr | IP Range for Nodes subnet (primary) | `string` | `null` | no |
| google_pods_ip_cidr | IP Range for Pods subnet (secondary) | `string` | `null` | no |
| google_svc_ip_cidr | IP Range for Services subnet (secondary) | `string` | `null` | no |

### Private Service Connect

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_psc | Enable both Dataplane Relay and REST API Private Service Connect? | `bool` | `null` | no |
| enable_dataplane_relay_psc | Enable Dataplane Relay Private Service Connect? | `bool` | `null` | no |
| enable_rest_api_psc | Enable REST API Private Service Connect? | `bool` | `null` | no |
| google_dataplane_relay_endpoint_vpc_name | Name of VPC Dataplane Relay Endpoint | `string` | `null` | no |
| google_dataplane_relay_endpoint_psc_name | Name of PSC Dataplane Relay Endpoint | `string` | `null` | no |
| google_dataplane_relay_endpoint_ip_name | Name of IP Dataplane Relay Endpoint | `string` | `null` | no |
| google_rest_api_endpoint_vpc_name | Name of VPC REST API Endpoint | `string` | `null` | no |
| google_rest_api_endpoint_psc_name | Name of PSC REST API Endpoint | `string` | `null` | no |
| google_rest_api_endpoint_ip_name | Name of IP REST API Endpoint | `string` | `null` | no |

## Outputs

### Workspace Outputs

| Name | Description |
|------|-------------|
| workspace_id | The ID of the Databricks workspace |
| workspace_url | The URL of the Databricks workspace |
| network_id | The ID of the Databricks network configuration |
| private_access_settings_id | The ID of the Databricks private access settings |

### VPC Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_name | The name of the VPC |

### Subnet Outputs

| Name | Description |
|------|-------------|
| primary_subnet_id | The ID of the primary subnet |
| pods_subnet_id | The ID of the pods subnet |
| services_subnet_id | The ID of the services subnet |

### PSC Outputs

| Name | Description |
|------|-------------|
| dataplane_relay_psc_endpoint_id | The ID of the dataplane relay PSC endpoint |
| rest_api_psc_endpoint_id | The ID of the REST API PSC endpoint |

## Notes

1. If `create_vpc` is set to `false`, the module will use an existing VPC with the name specified in `google_vpc_name`.
2. If `enable_psc` is set to `true`, both Dataplane Relay and REST API Private Service Connect endpoints will be created.
3. You can enable individual PSC endpoints by setting `enable_dataplane_relay_psc` or `enable_rest_api_psc` to `true`.
4. The module automatically calculates subnet CIDRs if not explicitly provided, using the `google_vpc_cidr` and `google_vpc_cidr_newbits` variables.
5. Resource names will be automatically generated using the `prefix` if specific names are not provided.

## Requirements for the GCP Service Account

The GCP service account used for deployment needs the following permissions:

- Compute Admin (`roles/compute.admin`)
- Kubernetes Engine Admin (`roles/container.admin`)
- Service Account User (`roles/iam.serviceAccountUser`)
- Project IAM Admin (`roles/resourcemanager.projectIamAdmin`)

Refer to the [Databricks documentation](https://docs.gcp.databricks.com/administration-guide/cloud-configurations/gcp/permissions.html) for detailed permission requirements.
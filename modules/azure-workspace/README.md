# Azure Databricks Workspace Module

This Terraform module deploys a Databricks workspace in Azure with the following components:

- Azure Virtual Network (VNet) with public and private subnets
- Network Security Group
- Route Table
- NAT Gateway for outbound connectivity
- Private Link endpoint (optional)
- Databricks workspace with network configuration

## Architecture

This module creates a Databricks workspace in Azure with the following architecture:

1. A Virtual Network (either newly created or existing)
2. Two subnets:
   - Public subnet for Databricks public endpoints
   - Private subnet for Databricks compute resources
3. Network Security Group for securing the subnets
4. Route Table for controlling network traffic
5. NAT Gateway for outbound connectivity
6. Optional Private Link endpoint for secure connectivity
7. Databricks workspace connected to the network configuration

## Requirements

| Name | Version |
|------|--------|
| terraform | >= 1.0.0 |
| databricks | >= 1.0.0 |
| azurerm | >= 3.0.0 |

## Providers

| Name | Version |
|------|--------|
| databricks | >= 1.0.0 |
| azurerm | >= 3.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_databricks_workspace.databricks_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace) | resource |
| [azurerm_virtual_network.databricks_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_subnet.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_network_security_group.databricks_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_route_table.databricks_route_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_nat_gateway.databricks_nat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_private_endpoint.databricks_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_dns_zone.databricks_dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |

| [databricks_mws_private_access_settings.private_access_setting](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_private_access_settings) | resource |


## Usage

### Basic Example - Create New Resources

```hcl
module "databricks_azure_workspace" {
  source = "path/to/modules/azure-workspace"

  # General
  prefix = "myproject"

  # Databricks
  databricks_account_id    = "12345678-1234-1234-1234-123456789012"
  databricks_client_id     = "12345678-1234-1234-1234-123456789012"
  databricks_client_secret = "your-client-secret"
  workspace_name           = "my-workspace"
  pricing_tier             = "premium"

  # Azure
  create_resource_group = true
  region        = "eastus"

  # Network - Create new VNet
  create_vnet     = true
  azure_vnet_cidr = "10.0.0.0/16"

  # Tags
  tags = {
    Environment = "Development"
    Project     = "Databricks"
  }
}
```

### Example - Use Existing Resources

```hcl
module "databricks_azure_workspace" {
  source = "path/to/modules/azure-workspace"

  # General
  prefix = "myproject"

  # Databricks
  databricks_account_id    = "12345678-1234-1234-1234-123456789012"
  databricks_client_id     = "12345678-1234-1234-1234-123456789012"
  databricks_client_secret = "your-client-secret"

  # Azure - Use existing resource group
  create_resource_group = false
  azure_resource_group  = "existing-resource-group"
  region        = "eastus"

  # Network - Use existing VNet
  create_vnet                = false
  azure_vnet_name           = "existing-vnet"
  azure_subnet_public_name  = "existing-public-subnet"
  azure_subnet_private_name = "existing-private-subnet"
}
```

### Example - With Private Link

```hcl
module "databricks_azure_workspace" {
  source = "path/to/modules/azure-workspace"

  # General
  prefix = "myproject"

  # Databricks
  databricks_account_id    = "12345678-1234-1234-1234-123456789012"
  databricks_client_id     = "12345678-1234-1234-1234-123456789012"
  databricks_client_secret = "your-client-secret"

  # Azure
  create_resource_group = true
  region        = "eastus"

  # Network
  create_vnet     = true
  azure_vnet_cidr = "10.0.0.0/16"

  # Private Link
  enable_private_link         = true
  azure_private_endpoint_name = "databricks-private-endpoint"

  # Tags
  tags = {
    Environment = "Production"
    Project     = "Databricks"
    Security    = "Private"
  }
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
| pricing_tier | Pricing Tier | `string` | `"premium"` | no |

### Azure

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_resource_group | Whether to create a new resource group | `bool` | `false` | no |
| azure_resource_group | Azure Resource Group Name (required if create_resource_group is false) | `string` | `null` | no |
| region | Azure Location | `string` | n/a | yes |
| azure_managed_resource_group_name | The name of the resource group where Azure should place the managed Databricks resources | `string` | `null` | no |

### Network Names

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_vnet | Terraform should create the VNet | `bool` | `true` | no |
| azure_vnet_name | VNet name used for deployment | `string` | `null` | no |
| azure_subnet_public_name | Public subnet name used for deployment | `string` | `null` | no |
| azure_subnet_private_name | Private subnet name used for deployment | `string` | `null` | no |
| azure_nsg_name | Name of the network security group to create | `string` | `null` | no |
| azure_route_table_name | Name of the route table to create | `string` | `null` | no |
| azure_nat_gateway_name | Name of the NAT gateway | `string` | `null` | no |

### Network CIDRs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azure_vnet_cidr | IP Range for VNet | `string` | `"10.0.0.0/16"` | no |
| azure_vnet_cidr_newbits | Number of new bits to automatically calculate the subnets mask | `number` | `8` | no |
| azure_subnet_public_cidr | IP Range for public subnet | `string` | `null` | no |
| azure_subnet_private_cidr | IP Range for private subnet | `string` | `null` | no |

### Private Link

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_private_link | Enable Azure Private Link for Databricks workspace? | `bool` | `false` | no |
| azure_private_endpoint_name | Name of the private endpoint | `string` | `null` | no |
| manage_private_access_settings | Whether this module should manage Databricks Account-level Private Access Settings (requires Accounts OAuth) | `bool` | `false` | no |

### Tags

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Tags

This module supports tagging of all created resources. You can specify tags using the `tags` variable:

```hcl
tags = {
  Environment = "Production"
  Project     = "Databricks"
  Owner       = "DataTeam"
  CostCenter  = "Engineering"
}
```

Tags will be applied to:
- Resource Group (if created)
- Virtual Network
- Subnets
- Network Security Group
- Route Table
- NAT Gateway
- Databricks Workspace
- Private Endpoint (if enabled)
- Private DNS Zone (if enabled)

## Outputs

### Workspace Outputs

| Name | Description |
|------|-------------|
| databricks_workspace_id | The ID of the Databricks workspace |
| databricks_workspace_url | The URL of the Databricks workspace |
| azure_databricks_workspace_id | The ID of the Azure Databricks workspace |
| azure_databricks_workspace_url | The URL of the Azure Databricks workspace |
| azure_managed_resource_group_name | The name of the managed resource group for the Azure Databricks workspace |
| azure_resource_group_name | The name of the resource group used for the Databricks workspace |
| databricks_private_access_settings_id | The ID of the Databricks private access settings |

### VNet Outputs

| Name | Description |
|------|-------------|
| azure_vnet_id | The ID of the VNet |
| azure_vnet_name | The name of the VNet |

### Subnet Outputs

| Name | Description |
|------|-------------|
| azure_subnet_public_id | The ID of the public subnet |
| azure_subnet_private_id | The ID of the private subnet |

### Private Link Outputs

| Name | Description |
|------|-------------|
| azure_private_endpoint_id | The ID of the private endpoint |

## Notes

1. If `create_resource_group` is set to `true`, the module will create a new resource group using the `prefix`. If set to `false`, you must provide an existing resource group name in `azure_resource_group`.
2. If `create_vnet` is set to `false`, the module will use an existing VNet with the name specified in `azure_vnet_name`.
3. If `enable_private_link` is set to `true`, a Private Link endpoint will be created for secure connectivity to the Databricks workspace.
4. The module automatically calculates subnet CIDRs if not explicitly provided, using the `azure_vnet_cidr` and `azure_vnet_cidr_newbits` variables.
5. Resource names will be automatically generated using the `prefix` if specific names are not provided.
6. The Azure Databricks workspace is created with the Azure resource (`azurerm_databricks_workspace`), with network configuration handled through custom_parameters. The `databricks_mws_private_access_settings` resource is used for private access settings.
7. Azure authentication (subscription ID, tenant ID, client credentials) should be configured through the Azure provider configuration or environment variables rather than module variables.

## Requirements for the Azure Service Principal

The Azure service principal used for deployment needs the following permissions:

- Contributor role on the Azure subscription or resource group
- Network Contributor role for VNet and subnet management
- User Access Administrator role for creating and managing role assignments
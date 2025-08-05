# Azure Databricks Workspace Example

This example demonstrates how to deploy a Databricks workspace in Azure using the `azure-workspace` module.

## Prerequisites

- Terraform 1.0+
- Azure CLI installed and configured
- Databricks account with admin privileges
- Service Principal with appropriate permissions in Azure

## Required Permissions

The Azure Service Principal used for deployment needs the following roles:

- Contributor on the subscription or resource group
- Network Contributor on the subscription or resource group
- User Access Administrator on the subscription or resource group (for creating role assignments)

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your specific values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your specific values.

3. Initialize Terraform:

```bash
terraform init
```

4. Plan the deployment:

```bash
terraform plan
```

5. Apply the configuration:

```bash
terraform apply
```

## Configuration Options

### VNet Creation

You can either create a new VNet or use an existing one:

- To create a new VNet: Set `create_vnet = true` and provide the desired CIDR ranges.
- To use an existing VNet: Set `create_vnet = false` and provide the names of your existing VNet and subnets.

### Private Link

To enable Private Link for secure connectivity:

- Set `enable_private_link = true`
- Ensure your Azure Service Principal has the necessary permissions to create Private Endpoints and DNS zones.

### Subnet CIDR Calculation

If you don't specify subnet CIDRs, they will be calculated automatically based on the VNet CIDR and the `azure_vnet_cidr_newbits` value.

## Outputs

After successful deployment, you can access various outputs including:

- Databricks workspace URL and ID
- Azure Databricks workspace URL and ID
- VNet and subnet IDs
- Private Endpoint ID (if enabled)

To view all outputs:

```bash
terraform output
```
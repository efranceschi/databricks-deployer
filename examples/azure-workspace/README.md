# Azure Databricks Workspace Example

This example demonstrates how to deploy a Databricks workspace in Azure using the `azure-workspace` module.

## Prerequisites

- Terraform 1.0+
- Azure CLI installed and configured
- Databricks account with admin privileges
- Service Principal with appropriate permissions in Azure

## Azure CLI Setup

### Installation

**macOS:**
```bash
brew install azure-cli
```

**Windows:**
```powershell
winget install Microsoft.AzureCLI
```

**Linux (Ubuntu/Debian):**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Authentication

1. **Login to Azure:**
   ```bash
   az login
   ```
   This will open a browser window for authentication.

2. **Set your subscription (if you have multiple):**
   ```bash
   az account list --output table
   az account set --subscription "your-subscription-id"
   ```

3. **Verify your current subscription:**
   ```bash
   az account show
   ```

### Service Principal Setup

For automated deployments, create a Service Principal:

1. **Create a Service Principal:**
   ```bash
   az ad sp create-for-rbac --name "databricks-terraform-sp" --role="Contributor" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID"
   ```

2. **Note the output values:**
   - `appId` (Client ID)
   - `password` (Client Secret)
   - `tenant` (Tenant ID)

3. **Set environment variables for Terraform:**
   ```bash
   export ARM_CLIENT_ID="your-client-id"
   export ARM_CLIENT_SECRET="your-client-secret"
   export ARM_SUBSCRIPTION_ID="your-subscription-id"
   export ARM_TENANT_ID="your-tenant-id"
   ```

   Or add them to your `terraform.tfvars` file:
   ```hcl
   azure_client_id       = "your-client-id"
   azure_client_secret   = "your-client-secret"
   azure_subscription_id = "your-subscription-id"
   azure_tenant_id       = "your-tenant-id"
   ```

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
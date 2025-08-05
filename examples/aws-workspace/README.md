# AWS Databricks Workspace Example

This example demonstrates how to deploy a Databricks workspace in AWS using the `aws-workspace` module.

## Prerequisites

- Terraform 1.0.0 or later
- AWS account with appropriate permissions
- Databricks account with appropriate permissions

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in the required variables:

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

This example supports various configuration options through variables:

### General
- `prefix`: Project prefix for naming resources

### Databricks
- `databricks_account_id`: Your Databricks Account ID
- `databricks_client_id`: Client ID for the service principal
- `databricks_client_secret`: Client Secret for the service principal
- `workspace_name`: The Databricks workspace name (optional)
- `pricing_tier`: Pricing tier for the workspace (default: PREMIUM)

### AWS
- `aws_region`: AWS region for deployment
- `aws_account_id`: AWS Account ID
- `aws_role_arn`: ARN of the role used for deployment

### Network
- `create_vpc`: Whether to create a new VPC (default: true)
- Various network resource names (optional if creating new resources)

### Private Link
- `enable_private_link`: Enable AWS PrivateLink for Databricks workspace (default: false)

### Tags
- `tags`: Map of tags to apply to resources

### Availability Zones
- `availability_zones`: List of availability zones to deploy subnets in (optional)

## Outputs

- `workspace_url`: The URL of the Databricks workspace
- `workspace_id`: The ID of the Databricks workspace
- `vpc_id`: The ID of the VPC
- `private_subnet_ids`: The IDs of the private subnets
- `public_subnet_ids`: The IDs of the public subnets
- `security_group_id`: The ID of the security group
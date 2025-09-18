# AWS Databricks Workspace Module

This Terraform module deploys a Databricks workspace in AWS with the following components:

- VPC with public, private, and service subnets
- Security groups
- NAT gateways and Internet gateway
- PrivateLink endpoints (optional)
- Databricks workspace

## Requirements

| Name | Version |
|------|--------|
| terraform | >= 0.13 |
| aws | >= 3.0 |
| databricks | >= 0.5.0 |

## Providers

| Name | Version |
|------|--------|
| aws | >= 3.0 |
| databricks | >= 0.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_vpc.databricks_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_internet_gateway.databricks_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_nat_gateway.databricks_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route.public_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.databricks_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_iam_role.databricks_cross_account_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.databricks_cross_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_vpc_endpoint.relay_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.rest_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [databricks_mws_networks.databricks_network](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_networks) | resource |
| [databricks_mws_private_access_settings.private_access_setting](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_private_access_settings) | resource |
| [databricks_mws_vpc_endpoint.relay_service](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint) | resource |
| [databricks_mws_vpc_endpoint.rest_api](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint) | resource |
| [databricks_mws_workspaces.databricks_workspace](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_workspaces) | resource |
| [databricks_mws_credentials.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_credentials) | resource |
| [aws_s3_bucket.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_versioning.root_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.root_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_public_access_block.root_bucket_pab](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_policy.root_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [databricks_mws_storage_configurations.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_storage_configurations) | resource |
| [time_sleep.wait_for_iam_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_iam_role.external_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [databricks_metastore.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/metastore) | data source |
| [databricks_metastore_assignment.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| prefix | Project prefix | `string` | n/a | yes |
| databricks_account_id | Databricks Account ID | `string` | n/a | yes |
| databricks_client_id | Client ID for the service principal | `string` | n/a | yes |
| databricks_client_secret | Client Secret for the service principal | `string` | n/a | yes |
| aws_region | AWS Region | `string` | n/a | yes |
| aws_role_arn | ARN of the role used for deployment. If not provided, a new role will be created | `string` | `null` | no |
| workspace_name | The Workspace name | `string` | `null` | no |
| network_config_name | The network configuration name | `string` | `null` | no |
| private_access_setting_name | The private access setting name | `string` | `null` | no |
| pricing_tier | Pricing Tier | `string` | `"ENTERPRISE"` | no |
| create_vpc | Terraform should create the VPC | `bool` | `true` | no |
| aws_vpc_name | VPC name used for deployment | `string` | `null` | no |
| aws_subnet_public_name_prefix | Prefix for public subnet names | `string` | `null` | no |
| aws_subnet_private_name_prefix | Prefix for private subnet names | `string` | `null` | no |
| aws_security_group_name | Name of the security group to create | `string` | `null` | no |
| aws_nat_gateway_name | Name of the NAT gateway | `string` | `null` | no |
| aws_internet_gateway_name | Name of the internet gateway | `string` | `null` | no |
| aws_vpc_cidr | IP Range for VPC | `string` | `"10.0.0.0/16"` | no |
| aws_vpc_cidr_newbits | Number of new bits to automatically calculate the subnets mask | `number` | `8` | no |
| aws_subnet_public_cidrs | IP Ranges for public subnets | `list(string)` | `null` | no |
| aws_subnet_private_cidrs | IP Ranges for private subnets | `list(string)` | `null` | no |
| enable_private_link | Enable AWS PrivateLink for Databricks workspace? | `bool` | `false` | no |
| aws_relay_service_endpoint_name | Name of the relay service VPC endpoint | `string` | `null` | no |
| aws_rest_api_endpoint_name | Name of the REST API VPC endpoint | `string` | `null` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |
| availability_zones | List of availability zones to deploy subnets in | `list(string)` | `null` | no |
| create_root_bucket | Whether to create a new S3 bucket for Databricks root storage | `bool` | `true` | no |
| root_bucket_name | Name of the S3 bucket for Databricks root storage | `string` | `null` | no |
| storage_configuration_name | Name for the Databricks storage configuration | `string` | `null` | no |
| metastore | Metastore name to assign to the workspace. If null, no metastore will be assigned. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| workspace_url | URL of the Databricks workspace |
| workspace_id | ID of the Databricks workspace |
| vpc_id | ID of the VPC |
| private_subnet_ids | IDs of the private subnets |
| public_subnet_ids | IDs of the public subnets |
| security_group_id | ID of the security group |
| role_arn | ARN of the IAM role used for Databricks deployment |
| storage_configuration_id | ID of the Databricks storage configuration |
| root_bucket_name | Name of the S3 bucket used for Databricks root storage |
| root_bucket_arn | ARN of the S3 bucket used for Databricks root storage |

## Usage

```hcl
module "databricks_workspace" {
  source = "../../modules/aws-workspace"

  ### General
  prefix = "myproject"

  ### Databricks
  databricks_account_id    = "12345678-1234-1234-1234-123456789012"
  databricks_client_id     = "01234567-89ab-cdef-0123-456789abcdef"
  databricks_client_secret = "your-client-secret"
  workspace_name           = "my-workspace"
  pricing_tier             = "ENTERPRISE"

  ### AWS
  aws_region   = "us-west-2"
  # aws_role_arn = "arn:aws:iam::123456789012:role/databricks-role"  # Optional: If not provided, a new role will be created

  ### Network
  create_vpc = true
  aws_vpc_cidr = "10.0.0.0/16"
  availability_zones = ["us-west-2a", "us-west-2b"]

  ### PrivateLink
  enable_private_link = true

  ### Tags
  tags = {
    Environment = "dev"
    Project     = "databricks"
  }
}
```
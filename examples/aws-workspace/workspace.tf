module "aws_workspace" {
  source = "../../modules/aws-workspace"

  # General
  prefix = var.prefix

  # Databricks
  databricks_account_id       = var.databricks_account_id
  databricks_client_id        = var.databricks_client_id
  databricks_client_secret    = var.databricks_client_secret
  workspace_name              = var.workspace_name
  network_config_name         = var.network_config_name
  private_access_setting_name = var.private_access_setting_name
  pricing_tier                = var.pricing_tier

  # AWS
  region   = var.region
  aws_role_arn = var.aws_role_arn

  # Network
  create_vpc                     = var.create_vpc
  aws_vpc_name                   = var.aws_vpc_name
  aws_subnet_public_name_prefix  = var.aws_subnet_public_name_prefix
  aws_subnet_private_name_prefix = var.aws_subnet_private_name_prefix
  aws_subnet_service_name_prefix = var.aws_subnet_service_name_prefix
  aws_security_group_name        = var.aws_security_group_name
  aws_nat_gateway_name           = var.aws_nat_gateway_name
  aws_internet_gateway_name      = var.aws_internet_gateway_name

  # Network CIDRs
  aws_vpc_cidr             = var.aws_vpc_cidr
  aws_vpc_cidr_newbits     = var.aws_vpc_cidr_newbits
  aws_subnet_public_cidrs  = var.aws_subnet_public_cidrs
  aws_subnet_private_cidrs = var.aws_subnet_private_cidrs
  aws_subnet_service_cidrs = var.aws_subnet_service_cidrs

  # Private Link
  enable_private_link             = var.enable_private_link
  aws_relay_service_endpoint_name = var.aws_relay_service_endpoint_name
  aws_rest_api_endpoint_name      = var.aws_rest_api_endpoint_name

  # Tags
  tags = var.tags

  # Availability Zones
  availability_zones = var.availability_zones

  # Storage
  create_root_bucket         = var.create_root_bucket
  root_bucket_name           = var.root_bucket_name
  storage_configuration_name = var.storage_configuration_name

  # Metastore
  metastore = var.metastore
}

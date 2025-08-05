module "aws_workspace" {
  source = "../../modules/aws-workspace"

  # General
  prefix = var.prefix

  # Databricks
  databricks_account_id       = var.databricks_account_id
  databricks_client_id        = var.databricks_client_id
  databricks_client_secret    = var.databricks_client_secret
  workspace_name              = var.workspace_name != null ? var.workspace_name : "${var.prefix}-workspace"
  network_config_name         = var.network_config_name != null ? var.network_config_name : "${var.prefix}-network"
  private_access_setting_name = var.private_access_setting_name != null ? var.private_access_setting_name : "${var.prefix}-private-access"
  pricing_tier                = var.pricing_tier

  # AWS
  aws_region   = var.aws_region
  aws_role_arn = var.aws_role_arn

  # Network
  create_vpc                     = var.create_vpc
  aws_vpc_name                   = var.aws_vpc_name != null ? var.aws_vpc_name : "${var.prefix}-vpc"
  aws_subnet_public_name_prefix  = var.aws_subnet_public_name_prefix != null ? var.aws_subnet_public_name_prefix : "${var.prefix}-public-subnet"
  aws_subnet_private_name_prefix = var.aws_subnet_private_name_prefix != null ? var.aws_subnet_private_name_prefix : "${var.prefix}-private-subnet"
  aws_security_group_name        = var.aws_security_group_name != null ? var.aws_security_group_name : "${var.prefix}-sg"
  aws_nat_gateway_name           = var.aws_nat_gateway_name != null ? var.aws_nat_gateway_name : "${var.prefix}-nat"
  aws_internet_gateway_name      = var.aws_internet_gateway_name != null ? var.aws_internet_gateway_name : "${var.prefix}-igw"

  # Network CIDRs
  aws_vpc_cidr             = var.aws_vpc_cidr
  aws_vpc_cidr_newbits     = var.aws_vpc_cidr_newbits
  aws_subnet_public_cidrs  = var.aws_subnet_public_cidrs
  aws_subnet_private_cidrs = var.aws_subnet_private_cidrs

  # Private Link
  enable_private_link             = var.enable_private_link
  aws_relay_service_endpoint_name = var.aws_relay_service_endpoint_name != null ? var.aws_relay_service_endpoint_name : "${var.prefix}-relay-endpoint"
  aws_rest_api_endpoint_name      = var.aws_rest_api_endpoint_name != null ? var.aws_rest_api_endpoint_name : "${var.prefix}-api-endpoint"

  # Tags
  tags = var.tags

  # Availability Zones
  availability_zones = var.availability_zones
}
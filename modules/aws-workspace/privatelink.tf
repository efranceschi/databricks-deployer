### Local Variables
locals {
  # Names
  final_network_config_name         = coalesce(var.network_config_name, "${var.prefix}-network")
  final_private_access_setting_name = coalesce(var.private_access_setting_name, "${var.prefix}-pas")

  # Endpoints
  final_aws_relay_service_endpoint_name = coalesce(var.aws_relay_service_endpoint_name, "${var.prefix}-relay-endpoint")
  final_aws_rest_api_endpoint_name      = coalesce(var.aws_rest_api_endpoint_name, "${var.prefix}-api-endpoint")

  # Service names by region
  # See https://docs.databricks.com/en/security/network/privatelink.html
  relay_service_name_by_region = {
    "us-east-1"      = "com.amazonaws.vpce.us-east-1.vpce-svc-02432a4f47c4e6cbd"
    "us-east-2"      = "com.amazonaws.vpce.us-east-2.vpce-svc-0129f463fcfbc46c5"
    "us-west-1"      = "com.amazonaws.vpce.us-west-1.vpce-svc-0da89cbbc5136df12"
    "us-west-2"      = "com.amazonaws.vpce.us-west-2.vpce-svc-0129f463fcfbc46c5"
    "ca-central-1"   = "com.amazonaws.vpce.ca-central-1.vpce-svc-0803ac3b4f1d2b2ab"
    "sa-east-1"      = "com.amazonaws.vpce.sa-east-1.vpce-svc-0d4c3e1c1092c7cad"
    "eu-west-1"      = "com.amazonaws.vpce.eu-west-1.vpce-svc-0da89cbbc5136df12"
    "eu-west-2"      = "com.amazonaws.vpce.eu-west-2.vpce-svc-0f9630f3b92f5e5a5"
    "eu-west-3"      = "com.amazonaws.vpce.eu-west-3.vpce-svc-0fc8b7d57f654c788"
    "eu-central-1"   = "com.amazonaws.vpce.eu-central-1.vpce-svc-081f78503812597d7"
    "eu-north-1"     = "com.amazonaws.vpce.eu-north-1.vpce-svc-0121108de96f8e3bb"
    "ap-south-1"     = "com.amazonaws.vpce.ap-south-1.vpce-svc-0d4c3e1c1092c7cad"
    "ap-northeast-1" = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02432a4f47c4e6cbd"
    "ap-northeast-2" = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0da89cbbc5136df12"
    "ap-southeast-1" = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0129f463fcfbc46c5"
    "ap-southeast-2" = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0da89cbbc5136df12"
  }
  final_relay_service_name = local.relay_service_name_by_region[var.aws_region]

  rest_api_service_name_by_region = {
    "us-east-1"      = "com.amazonaws.vpce.us-east-1.vpce-svc-09143d1e626de2f04"
    "us-east-2"      = "com.amazonaws.vpce.us-east-2.vpce-svc-041dc2b4d7796b8d3"
    "us-west-1"      = "com.amazonaws.vpce.us-west-1.vpce-svc-0b81b48bfb3225e0d"
    "us-west-2"      = "com.amazonaws.vpce.us-west-2.vpce-svc-0ed7a8c3e2c3b2a7a"
    "ca-central-1"   = "com.amazonaws.vpce.ca-central-1.vpce-svc-0a4cd8e5e3d98df7c"
    "sa-east-1"      = "com.amazonaws.vpce.sa-east-1.vpce-svc-0b81b48bfb3225e0d"
    "eu-west-1"      = "com.amazonaws.vpce.eu-west-1.vpce-svc-09c62c99b5c6e6f7c"
    "eu-west-2"      = "com.amazonaws.vpce.eu-west-2.vpce-svc-0b81b48bfb3225e0d"
    "eu-west-3"      = "com.amazonaws.vpce.eu-west-3.vpce-svc-0ac31de46e1ff6e7c"
    "eu-central-1"   = "com.amazonaws.vpce.eu-central-1.vpce-svc-0b81b48bfb3225e0d"
    "eu-north-1"     = "com.amazonaws.vpce.eu-north-1.vpce-svc-0b81b48bfb3225e0d"
    "ap-south-1"     = "com.amazonaws.vpce.ap-south-1.vpce-svc-0b81b48bfb3225e0d"
    "ap-northeast-1" = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-0b81b48bfb3225e0d"
    "ap-northeast-2" = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0b81b48bfb3225e0d"
    "ap-southeast-1" = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0b81b48bfb3225e0d"
    "ap-southeast-2" = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b81b48bfb3225e0d"
  }
  final_rest_api_service_name = local.rest_api_service_name_by_region[var.aws_region]
}

### VPC Endpoints for PrivateLink
resource "aws_vpc_endpoint" "relay_service" {
  count               = var.enable_private_link ? 1 : 0
  vpc_id              = var.create_vpc ? aws_vpc.databricks_vpc[0].id : data.aws_vpc.existing_vpc[0].id
  service_name        = local.final_relay_service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [var.create_vpc ? aws_security_group.databricks_sg[0].id : data.aws_security_group.existing_sg[0].id]
  subnet_ids          = var.create_vpc ? aws_subnet.private[*].id : data.aws_subnet.existing_private[*].id
  private_dns_enabled = true
  tags = merge(var.tags, {
    Name = local.final_aws_relay_service_endpoint_name
  })
}

resource "aws_vpc_endpoint" "rest_api" {
  count               = var.enable_private_link ? 1 : 0
  vpc_id              = var.create_vpc ? aws_vpc.databricks_vpc[0].id : data.aws_vpc.existing_vpc[0].id
  service_name        = local.final_rest_api_service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [var.create_vpc ? aws_security_group.databricks_sg[0].id : data.aws_security_group.existing_sg[0].id]
  subnet_ids          = var.create_vpc ? aws_subnet.private[*].id : data.aws_subnet.existing_private[*].id
  private_dns_enabled = true
  tags = merge(var.tags, {
    Name = local.final_aws_rest_api_endpoint_name
  })
}

### Data sources for existing resources when not creating VPC
data "aws_security_group" "existing_sg" {
  count = var.create_vpc ? 0 : 1
  filter {
    name   = "tag:Name"
    values = [local.final_aws_security_group_name]
  }
}

data "aws_subnet" "existing_private" {
  count = var.create_vpc ? 0 : length(local.final_availability_zones)
  filter {
    name   = "tag:Name"
    values = ["${local.final_aws_subnet_private_name_prefix}-${count.index + 1}"]
  }
}

### Databricks VPC Endpoints
resource "databricks_mws_vpc_endpoint" "relay_service" {
  count             = var.enable_private_link ? 1 : 0
  account_id        = var.databricks_account_id
  vpc_endpoint_name = local.final_aws_relay_service_endpoint_name
  aws_vpc_endpoint_id = aws_vpc_endpoint.relay_service[0].id
  aws_endpoint_service_id = local.final_relay_service_name
  region             = var.aws_region
}

resource "databricks_mws_vpc_endpoint" "rest_api" {
  count             = var.enable_private_link ? 1 : 0
  account_id        = var.databricks_account_id
  vpc_endpoint_name = local.final_aws_rest_api_endpoint_name
  aws_vpc_endpoint_id = aws_vpc_endpoint.rest_api[0].id
  aws_endpoint_service_id = local.final_rest_api_service_name
  region             = var.aws_region
}

### Databricks Network
resource "databricks_mws_networks" "databricks_network" {
  account_id   = var.databricks_account_id
  network_name = local.final_network_config_name
  vpc_id       = var.create_vpc ? aws_vpc.databricks_vpc[0].id : data.aws_vpc.existing_vpc[0].id
  subnet_ids   = var.create_vpc ? aws_subnet.private[*].id : data.aws_subnet.existing_private[*].id
  security_group_ids = [
    var.create_vpc ? aws_security_group.databricks_sg[0].id : data.aws_security_group.existing_sg[0].id
  ]
  vpc_endpoints {
    dataplane_relay = var.enable_private_link ? [databricks_mws_vpc_endpoint.relay_service[0].vpc_endpoint_id] : []
    rest_api        = var.enable_private_link ? [databricks_mws_vpc_endpoint.rest_api[0].vpc_endpoint_id] : []
  }
}

### Databricks Private Access Setting
resource "databricks_mws_private_access_settings" "private_access_setting" {
  private_access_settings_name = local.final_private_access_setting_name
  region                       = var.aws_region
  public_access_enabled        = true
  private_access_level         = var.enable_private_link ? "ACCOUNT" : "ENDPOINT"
}
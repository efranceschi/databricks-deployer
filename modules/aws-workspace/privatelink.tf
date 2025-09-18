### Local Variables
locals {
  # Names
  final_network_config_name         = coalesce(var.network_config_name, "${var.prefix}-network")
  final_private_access_setting_name = coalesce(var.private_access_setting_name, "${var.prefix}-pas")

  # Endpoints
  final_aws_relay_service_endpoint_name = coalesce(var.aws_relay_service_endpoint_name, "${var.prefix}-relay-endpoint")
  final_aws_rest_api_endpoint_name      = coalesce(var.aws_rest_api_endpoint_name, "${var.prefix}-api-endpoint")

  # Databricks PrivateLink service names by AWS region
  # These are Databricks-managed VPC endpoint service names for the relay/backend service
  # Reference: https://docs.databricks.com/aws/en/resources/ip-domain-region#privatelink-vpc-endpoint-services
  rest_api_service_name_by_region = {
    "ap-northeast-1" = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02691fd610d24fd64"
    "ap-northeast-2" = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0babb9bde64f34d7e"
    "ap-south-1"     = "com.amazonaws.vpce.ap-south-1.vpce-svc-0dbfe5d9ee18d6411"
    "ap-southeast-1" = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-02535b257fc253ff4"
    "ap-southeast-2" = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b87155ddd6954974"
    "ap-southeast-3" = ""
    "ca-central-1"   = "com.amazonaws.vpce.ca-central-1.vpce-svc-0205f197ec0e28d65"
    "eu-central-1"   = "com.amazonaws.vpce.eu-central-1.vpce-svc-081f78503812597f7"
    "eu-west-1"      = "com.amazonaws.vpce.eu-west-1.vpce-svc-0da6ebf1461278016"
    "eu-west-2"      = "com.amazonaws.vpce.eu-west-2.vpce-svc-01148c7cdc1d1326c"
    "eu-west-3"      = "com.amazonaws.vpce.eu-west-3.vpce-svc-008b9368d1d011f37"
    "sa-east-1"      = "com.amazonaws.vpce.sa-east-1.vpce-svc-0bafcea8cdfe11b66"
    "us-east-1"      = "com.amazonaws.vpce.us-east-1.vpce-svc-09143d1e626de2f04"
    "us-east-2"      = "com.amazonaws.vpce.us-east-2.vpce-svc-041dc2b4d7796b8d3"
    "us-west-1"      = "com.amazonaws.vpce.us-west-1.vpce-svc-09bb6ca26208063f2"
    "us-west-2"      = "com.amazonaws.vpce.us-west-2.vpce-svc-0129f463fcfbc46c5"
  }
  final_rest_api_service_name = local.rest_api_service_name_by_region[var.region]

  relay_service_name_by_region = {
    "ap-northeast-1" = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02aa633bda3edbec0"
    "ap-northeast-2" = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0dc0e98a5800db5c4"
    "ap-south-1"     = "com.amazonaws.vpce.ap-south-1.vpce-svc-03fd4d9b61414f3de"
    "ap-southeast-1" = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0557367c6fc1a0c5c"
    "ap-southeast-2" = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b4a72e8f825495f6"
    "ap-southeast-3" = "com.amazonaws.vpce.ap-southeast-3.vpce-svc-025ca447c232c6a1b"
    "ca-central-1"   = "com.amazonaws.vpce.ca-central-1.vpce-svc-0c4e25bdbcbfbb684"
    "eu-central-1"   = "com.amazonaws.vpce.eu-central-1.vpce-svc-08e5dfca9572c85c4"
    "eu-west-1"      = "com.amazonaws.vpce.eu-west-1.vpce-svc-09b4eb2bc775f4e8c"
    "eu-west-2"      = "com.amazonaws.vpce.eu-west-2.vpce-svc-05279412bf5353a45"
    "eu-west-3"      = "com.amazonaws.vpce.eu-west-3.vpce-svc-005b039dd0b5f857d"
    "sa-east-1"      = "com.amazonaws.vpce.sa-east-1.vpce-svc-0e61564963be1b43f"
    "us-east-1"      = "com.amazonaws.vpce.us-east-1.vpce-svc-00018a8c3ff62ffdf"
    "us-east-2"      = "com.amazonaws.vpce.us-east-2.vpce-svc-090a8fab0d73e39a6"
    "us-west-1"      = "com.amazonaws.vpce.us-west-1.vpce-svc-04cb91f9372b792fe"
    "us-west-2"      = "com.amazonaws.vpce.us-west-2.vpce-svc-0158114c0c730c3bb"
  }
  final_relay_service_name = local.relay_service_name_by_region[var.region]

}

### VPC Endpoints for PrivateLink
# Create VPC endpoint for Databricks relay/backend service
# This endpoint handles cluster communication and data plane traffic
# Reference: https://docs.databricks.com/en/security/network/privatelink.html#step-2-create-a-vpc-endpoint-for-the-relay
resource "aws_vpc_endpoint" "relay_service" {
  count               = var.enable_private_link ? 1 : 0
  vpc_id              = var.create_vpc ? aws_vpc.databricks_vpc[0].id : data.aws_vpc.existing_vpc[0].id
  service_name        = local.final_relay_service_name # Databricks-managed service name
  vpc_endpoint_type   = "Interface"                    # Interface endpoint for private connectivity
  security_group_ids  = [var.create_vpc ? aws_security_group.databricks_sg[0].id : data.aws_security_group.existing_sg[0].id]
  subnet_ids          = var.create_vpc ? aws_subnet.service[*].id : data.aws_subnet.existing_service[*].id
  private_dns_enabled = true # Enable private DNS resolution
  tags = merge(var.tags, {
    Name = local.final_aws_relay_service_endpoint_name
  })
}

# Create VPC endpoint for Databricks REST API service
# This endpoint handles workspace API calls and web application traffic
# Reference: https://docs.databricks.com/en/security/network/privatelink.html#step-3-create-a-vpc-endpoint-for-the-rest-api
resource "aws_vpc_endpoint" "rest_api" {
  count               = var.enable_private_link ? 1 : 0
  vpc_id              = var.create_vpc ? aws_vpc.databricks_vpc[0].id : data.aws_vpc.existing_vpc[0].id
  service_name        = local.final_rest_api_service_name # Databricks-managed service name
  vpc_endpoint_type   = "Interface"                       # Interface endpoint for private connectivity
  security_group_ids  = [var.create_vpc ? aws_security_group.databricks_sg[0].id : data.aws_security_group.existing_sg[0].id]
  subnet_ids          = var.create_vpc ? aws_subnet.service[*].id : data.aws_subnet.existing_service[*].id
  private_dns_enabled = true # Enable private DNS resolution
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

data "aws_subnet" "existing_service" {
  count = var.create_vpc ? 0 : length(local.final_availability_zones)
  filter {
    name   = "tag:Name"
    values = ["${local.final_aws_subnet_service_name_prefix}-${count.index + 1}"]
  }
}

### Databricks VPC Endpoints
# Register AWS VPC endpoint with Databricks for relay/backend service
# This creates a Databricks-managed VPC endpoint configuration
# Reference: https://docs.databricks.com/dev-tools/api/latest/account.html#operation/create-vpc-endpoint
resource "databricks_mws_vpc_endpoint" "relay_service" {
  count                   = var.enable_private_link ? 1 : 0
  account_id              = var.databricks_account_id                   # Databricks account ID
  vpc_endpoint_name       = local.final_aws_relay_service_endpoint_name # Unique name for the VPC endpoint
  aws_vpc_endpoint_id     = aws_vpc_endpoint.relay_service[0].id        # AWS VPC endpoint ID
  region                  = var.region                              # AWS region
  depends_on = [
    aws_vpc_endpoint.relay_service
  ]
}

# Register AWS VPC endpoint with Databricks for REST API service
# This creates a Databricks-managed VPC endpoint configuration
# Reference: https://docs.databricks.com/dev-tools/api/latest/account.html#operation/create-vpc-endpoint
resource "databricks_mws_vpc_endpoint" "rest_api" {
  count                   = var.enable_private_link ? 1 : 0
  account_id              = var.databricks_account_id              # Databricks account ID
  vpc_endpoint_name       = local.final_aws_rest_api_endpoint_name # Unique name for the VPC endpoint
  aws_vpc_endpoint_id     = aws_vpc_endpoint.rest_api[0].id        # AWS VPC endpoint ID
  region                  = var.region                         # AWS region
  depends_on = [
    aws_vpc_endpoint.rest_api
  ]
}

### Databricks Network
# Configure network settings for Databricks workspace
# This defines the VPC, subnets, security groups, and VPC endpoints for the workspace
# Reference: https://docs.databricks.com/dev-tools/api/latest/account.html#operation/create-network-configuration
resource "databricks_mws_networks" "databricks_network" {
  account_id   = var.databricks_account_id                                                          # Databricks account ID
  network_name = local.final_network_config_name                                                    # Network configuration name
  vpc_id       = var.create_vpc ? aws_vpc.databricks_vpc[0].id : data.aws_vpc.existing_vpc[0].id    # VPC ID
  subnet_ids   = var.create_vpc ? aws_subnet.private[*].id : data.aws_subnet.existing_private[*].id # Private subnet IDs
  security_group_ids = [                                                                            # Security group IDs
    var.create_vpc ? aws_security_group.databricks_sg[0].id : data.aws_security_group.existing_sg[0].id
  ]
  dynamic "vpc_endpoints" {
    for_each = var.enable_private_link ? [1] : []
    content {
      dataplane_relay = [databricks_mws_vpc_endpoint.relay_service[0].vpc_endpoint_id] # Relay service endpoint
      rest_api        = [databricks_mws_vpc_endpoint.rest_api[0].vpc_endpoint_id]      # REST API endpoint
    }
  }
}

### Databricks Private Access Setting
# Configure private access settings for the Databricks workspace
# This controls how the workspace can be accessed (publicly and/or privately)
# Reference: https://docs.databricks.com/dev-tools/api/latest/account.html#operation/create-private-access-settings
resource "databricks_mws_private_access_settings" "private_access_setting" {
  private_access_settings_name = local.final_private_access_setting_name          # Unique name for private access settings
  region                       = var.region                                   # AWS region
  public_access_enabled        = true                                             # Allow public internet access
  private_access_level         = var.enable_private_link ? "ACCOUNT" : "ENDPOINT" # Private access level: ACCOUNT (full PrivateLink) or ENDPOINT (VPC endpoints only)
}

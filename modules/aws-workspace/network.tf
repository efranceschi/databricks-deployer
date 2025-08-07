### Local Variables
locals {
  # Names
  final_aws_vpc_name                   = coalesce(var.aws_vpc_name, "${var.prefix}-vpc")
  final_aws_subnet_public_name_prefix  = coalesce(var.aws_subnet_public_name_prefix, "${var.prefix}-public-subnet")
  final_aws_subnet_private_name_prefix = coalesce(var.aws_subnet_private_name_prefix, "${var.prefix}-private-subnet")
  final_aws_subnet_service_name_prefix = coalesce(var.aws_subnet_service_name_prefix, "${var.prefix}-service-subnet")
  final_aws_security_group_name        = coalesce(var.aws_security_group_name, "${var.prefix}-sg")
  final_aws_nat_gateway_name           = coalesce(var.aws_nat_gateway_name, "${var.prefix}-nat")
  final_aws_internet_gateway_name      = coalesce(var.aws_internet_gateway_name, "${var.prefix}-igw")

  # Availability Zones. Default to the first two AZs if not provided
  final_availability_zones = coalesce(var.availability_zones, slice(data.aws_availability_zones.available.names, 0, 2))

  # CIDRs
  final_aws_subnet_public_cidrs = coalesce(var.aws_subnet_public_cidrs, [
    for i in range(length(local.final_availability_zones)) :
    cidrsubnet(var.aws_vpc_cidr, var.aws_vpc_cidr_newbits, i)
  ])

  final_aws_subnet_private_cidrs = coalesce(var.aws_subnet_private_cidrs, [
    for i in range(length(local.final_availability_zones)) :
    cidrsubnet(var.aws_vpc_cidr, var.aws_vpc_cidr_newbits, i + length(local.final_availability_zones))
  ])

  final_aws_subnet_service_cidrs = coalesce(var.aws_subnet_service_cidrs, [
    for i in range(length(local.final_availability_zones)) :
    cidrsubnet(var.aws_vpc_cidr, var.aws_vpc_cidr_newbits, i + (2 * length(local.final_availability_zones)))
  ])
}

### VPC
resource "aws_vpc" "databricks_vpc" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    Name = local.final_aws_vpc_name
  })
}

data "aws_vpc" "existing_vpc" {
  count = var.create_vpc ? 0 : 1
  filter {
    name   = "tag:Name"
    values = [local.final_aws_vpc_name]
  }
}

# Fetch available Availability Zones
data "aws_availability_zones" "available" {}

### Internet Gateway
resource "aws_internet_gateway" "databricks_igw" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.databricks_vpc[0].id
  tags = merge(var.tags, {
    Name = local.final_aws_internet_gateway_name
  })
}

### Public Subnets
resource "aws_subnet" "public" {
  count                   = var.create_vpc ? length(local.final_availability_zones) : 0
  vpc_id                  = aws_vpc.databricks_vpc[0].id
  cidr_block              = local.final_aws_subnet_public_cidrs[count.index]
  availability_zone       = local.final_availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "${local.final_aws_subnet_public_name_prefix}-${count.index + 1}"
  })
}

### Private Subnets
resource "aws_subnet" "private" {
  count                   = var.create_vpc ? length(local.final_availability_zones) : 0
  vpc_id                  = aws_vpc.databricks_vpc[0].id
  cidr_block              = local.final_aws_subnet_private_cidrs[count.index]
  availability_zone       = local.final_availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "${local.final_aws_subnet_private_name_prefix}-${count.index + 1}"
  })
}

### Service Subnets (for VPC Endpoints)
# These subnets are dedicated to hosting VPC endpoints for Databricks PrivateLink
# Reference: https://docs.databricks.com/en/security/network/privatelink.html
resource "aws_subnet" "service" {
  count                   = var.create_vpc ? length(local.final_availability_zones) : 0
  vpc_id                  = aws_vpc.databricks_vpc[0].id
  cidr_block              = local.final_aws_subnet_service_cidrs[count.index]
  availability_zone       = local.final_availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "${local.final_aws_subnet_service_name_prefix}-${count.index + 1}"
  })
}

### Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = var.create_vpc ? length(local.final_availability_zones) : 0
  domain = "vpc"
  tags = merge(var.tags, {
    Name = "${local.final_aws_nat_gateway_name}-eip-${count.index + 1}"
  })
}

### NAT Gateways
resource "aws_nat_gateway" "databricks_nat" {
  count         = var.create_vpc ? length(local.final_availability_zones) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = merge(var.tags, {
    Name = "${local.final_aws_nat_gateway_name}-${count.index + 1}"
  })
  depends_on = [aws_internet_gateway.databricks_igw]
}

### Route Tables
resource "aws_route_table" "public" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.databricks_vpc[0].id
  tags = merge(var.tags, {
    Name = "${var.prefix}-public-rt"
  })
}

resource "aws_route" "public_internet_gateway" {
  count                  = var.create_vpc ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.databricks_igw[0].id
}

resource "aws_route_table_association" "public" {
  count          = var.create_vpc ? length(local.final_availability_zones) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  count  = var.create_vpc ? length(local.final_availability_zones) : 0
  vpc_id = aws_vpc.databricks_vpc[0].id
  tags = merge(var.tags, {
    Name = "${var.prefix}-private-rt-${count.index + 1}"
  })
}

resource "aws_route" "private_nat_gateway" {
  count                  = var.create_vpc ? length(local.final_availability_zones) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.databricks_nat[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = var.create_vpc ? length(local.final_availability_zones) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "service" {
  count          = var.create_vpc ? length(local.final_availability_zones) : 0
  subnet_id      = aws_subnet.service[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

### Security Group
# Create security group for Databricks cluster nodes
# Reference: https://docs.databricks.com/administration-guide/cloud-configurations/aws/customer-managed-vpc.html#security-group-rules
resource "aws_security_group" "databricks_sg" {
  count       = var.create_vpc ? 1 : 0
  name        = local.final_aws_security_group_name
  description = "Security group for Databricks workspace"
  vpc_id      = aws_vpc.databricks_vpc[0].id

  # Allow all communication between cluster nodes within the same security group
  # This is required for Databricks cluster internal communication
  # Reference: https://docs.databricks.com/administration-guide/cloud-configurations/aws/customer-managed-vpc.html#inbound-rules
  ingress {
    description = "Allow all internal traffic between Databricks cluster nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    self        = true   # Allow traffic from the same security group
  }

  # Allow all outbound traffic for cluster nodes to access external services
  # This includes access to Databricks control plane, S3, package repositories, etc.
  # Reference: https://docs.databricks.com/administration-guide/cloud-configurations/aws/customer-managed-vpc.html#outbound-rules
  egress {
    description = "Allow all outbound traffic for external service access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # All destinations
  }

  tags = merge(var.tags, {
    Name = local.final_aws_security_group_name
  })
}
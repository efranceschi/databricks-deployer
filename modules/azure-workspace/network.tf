### Local Variables
locals {
  # Names
  final_azure_resource_group_name = var.create_resource_group ? "${var.prefix}-rg" : var.azure_resource_group
  final_azure_vnet_name           = coalesce(var.azure_vnet_name, "${var.prefix}-vnet")
  final_azure_subnet_public_name  = coalesce(var.azure_subnet_public_name, "${var.prefix}-public-subnet")
  final_azure_subnet_private_name = coalesce(var.azure_subnet_private_name, "${var.prefix}-private-subnet")
  final_azure_nsg_name            = coalesce(var.azure_nsg_name, "${var.prefix}-nsg")
  final_azure_route_table_name    = coalesce(var.azure_route_table_name, "${var.prefix}-route-table")
  final_azure_nat_gateway_name    = coalesce(var.azure_nat_gateway_name, "${var.prefix}-nat")

  # CIDRs
  final_azure_subnet_public_cidr  = coalesce(var.azure_subnet_public_cidr, cidrsubnet(var.azure_vnet_cidr, var.azure_vnet_cidr_newbits, 0))
  final_azure_subnet_private_cidr = coalesce(var.azure_subnet_private_cidr, cidrsubnet(var.azure_vnet_cidr, var.azure_vnet_cidr_newbits, 1))
}

### Resource Group
resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = local.final_azure_resource_group_name
  location = var.azure_location
  tags     = var.tags
}

data "azurerm_resource_group" "existing" {
  count = var.create_resource_group ? 0 : 1
  name  = var.azure_resource_group
}

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.this[0].name : data.azurerm_resource_group.existing[0].name
}

### Virtual Network
resource "azurerm_virtual_network" "databricks_vnet" {
  count               = var.create_vnet ? 1 : 0
  name                = local.final_azure_vnet_name
  resource_group_name = local.resource_group_name
  location            = var.azure_location
  address_space       = [var.azure_vnet_cidr]
  tags                = var.tags
}

data "azurerm_virtual_network" "existing_vnet" {
  count               = var.create_vnet ? 0 : 1
  name                = local.final_azure_vnet_name
  resource_group_name = local.resource_group_name
}

### Network Security Group
resource "azurerm_network_security_group" "databricks_nsg" {
  count               = var.create_vnet ? 1 : 0
  name                = local.final_azure_nsg_name
  resource_group_name = local.resource_group_name
  location            = var.azure_location
  tags                = var.tags
}

### Route Table
resource "azurerm_route_table" "databricks_route_table" {
  count               = var.create_vnet ? 1 : 0
  name                = local.final_azure_route_table_name
  resource_group_name = local.resource_group_name
  location            = var.azure_location
  tags                = var.tags
}

### NAT Gateway
resource "azurerm_public_ip" "nat_gateway_ip" {
  count               = var.create_vnet ? 1 : 0
  name                = "${local.final_azure_nat_gateway_name}-ip"
  resource_group_name = local.resource_group_name
  location            = var.azure_location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "databricks_nat" {
  count               = var.create_vnet ? 1 : 0
  name                = local.final_azure_nat_gateway_name
  resource_group_name = local.resource_group_name
  location            = var.azure_location
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_ip_association" {
  count                = var.create_vnet ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.databricks_nat[0].id
  public_ip_address_id = azurerm_public_ip.nat_gateway_ip[0].id
}

### Subnets
resource "azurerm_subnet" "public" {
  count                = var.create_vnet ? 1 : 0
  name                 = local.final_azure_subnet_public_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.databricks_vnet[0].name
  address_prefixes     = [local.final_azure_subnet_public_cidr]

  delegation {
    name = "databricks-delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}

resource "azurerm_subnet" "private" {
  count                = var.create_vnet ? 1 : 0
  name                 = local.final_azure_subnet_private_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.databricks_vnet[0].name
  address_prefixes     = [local.final_azure_subnet_private_cidr]

  delegation {
    name = "databricks-delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}

### Subnet Associations
resource "azurerm_subnet_network_security_group_association" "public_nsg" {
  count                     = var.create_vnet ? 1 : 0
  subnet_id                 = azurerm_subnet.public[0].id
  network_security_group_id = azurerm_network_security_group.databricks_nsg[0].id
}

resource "azurerm_subnet_network_security_group_association" "private_nsg" {
  count                     = var.create_vnet ? 1 : 0
  subnet_id                 = azurerm_subnet.private[0].id
  network_security_group_id = azurerm_network_security_group.databricks_nsg[0].id
}

resource "azurerm_subnet_route_table_association" "public_route_table" {
  count          = var.create_vnet ? 1 : 0
  subnet_id      = azurerm_subnet.public[0].id
  route_table_id = azurerm_route_table.databricks_route_table[0].id
}

resource "azurerm_subnet_route_table_association" "private_route_table" {
  count          = var.create_vnet ? 1 : 0
  subnet_id      = azurerm_subnet.private[0].id
  route_table_id = azurerm_route_table.databricks_route_table[0].id
}

resource "azurerm_subnet_nat_gateway_association" "private_nat" {
  count          = var.create_vnet ? 1 : 0
  subnet_id      = azurerm_subnet.private[0].id
  nat_gateway_id = azurerm_nat_gateway.databricks_nat[0].id
}

### Data sources for existing resources when not creating VNet
data "azurerm_subnet" "existing_public" {
  count                = var.create_vnet ? 0 : 1
  name                 = local.final_azure_subnet_public_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.final_azure_vnet_name
}

data "azurerm_subnet" "existing_private" {
  count                = var.create_vnet ? 0 : 1
  name                 = local.final_azure_subnet_private_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.final_azure_vnet_name
}

data "azurerm_network_security_group" "existing_nsg" {
  count               = var.create_vnet ? 0 : 1
  name                = local.final_azure_nsg_name
  resource_group_name = local.resource_group_name
}
### General
variable "prefix" {
  type        = string
  description = "Project prefix"
  validation {
    condition = length(var.prefix) < 20
    error_message = "Please, use a variable name with a maximum 20 characters long"
  }
}

### Databricks
variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "databricks_client_secret" {
  type        = string
  description = "Client Secret for the service principal"
}

variable "databricks_client_id" {
  type        = string
  description = "Client ID for the service principal"
}

variable "workspace_name" {
  type        = string
  description = "The Workspace name"
  default     = null
}

variable "network_config_name" {
  type        = string
  description = "The network configuration name"
  default     = null
}

variable "private_access_setting_name" {
  type        = string
  description = "The private access setting name"
  default     = null
}

variable "pricing_tier" {
  type        = string
  description = "Pricing Tier"
  default     = "premium"
}

### Azure
variable "create_resource_group" {
  type        = bool
  description = "Whether to create a new resource group"
  default     = false
}

variable "azure_resource_group" {
  type        = string
  description = "Azure Resource Group Name (required if create_resource_group is false)"
  default     = null
}

variable "azure_location" {
  type        = string
  description = "Azure Location"
}

variable "azure_managed_resource_group_name" {
  type        = string
  description = "The name of the resource group where Azure should place the managed Databricks resources"
  default     = null
}

### Network Names
variable "azure_vnet_name" {
  type        = string
  description = "VNet name used for deployment"
  default     = null
}

variable "create_vnet" {
  type        = bool
  description = "Terraform should create the VNet"
  default     = true
}

variable "azure_subnet_public_name" {
  type        = string
  description = "Public subnet name used for deployment"
  default     = null
}

variable "azure_subnet_private_name" {
  type        = string
  description = "Private subnet name used for deployment"
  default     = null
}

variable "azure_nsg_name" {
  type        = string
  description = "Name of the network security group to create"
  default     = null
}

variable "azure_route_table_name" {
  type        = string
  description = "Name of the route table to create"
  default     = null
}

variable "azure_nat_gateway_name" {
  type        = string
  description = "Name of the NAT gateway"
  default     = null
}

### Network CIDRs
variable "azure_vnet_cidr" {
  type        = string
  description = "IP Range for VNet"
  default     = "10.0.0.0/16"
}

variable "azure_vnet_cidr_newbits" {
  type        = number
  description = "Number of new bits to automatically calculate the subnets mask"
  default     = 8
}

variable "azure_subnet_public_cidr" {
  type        = string
  description = "IP Range for public subnet"
  default     = null
}

variable "azure_subnet_private_cidr" {
  type        = string
  description = "IP Range for private subnet"
  default     = null
}

### Private Link
variable "enable_private_link" {
  type        = bool
  description = "Enable Azure Private Link for Databricks workspace?"
  default     = false
}

variable "azure_private_endpoint_name" {
  type        = string
  description = "Name of the private endpoint"
  default     = null
}

### Tags
variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
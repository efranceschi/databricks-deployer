### General
variable "prefix" {
  type        = string
  description = "Project prefix"
  validation {
    condition     = length(var.prefix) < 20
    error_message = "Please, use a variable name with a maximum 20 charecters long"
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
  description = "Pricing Tier. Allowed values: PREMIUM or ENTERPRISE"
  default     = "ENTERPRISE"
  validation {
    condition     = contains(["PREMIUM", "ENTERPRISE"], var.pricing_tier)
    error_message = "The pricing_tier variable must be either 'PREMIUM' or 'ENTERPRISE'."
  }
}

### AWS
variable "region" {
  type        = string
  description = "AWS Region"
}

variable "aws_role_arn" {
  type        = string
  description = "ARN of the role used for deployment. If not provided, a new role will be created."
  default     = null
}

### Network Names
variable "aws_vpc_name" {
  type        = string
  description = "VPC name used for deployment"
  default     = null
}

variable "create_vpc" {
  type        = bool
  description = "Terraform should create the VPC"
  default     = true
}

variable "aws_subnet_public_name" {
  type        = string
  description = "Prefix for public subnet names"
  default     = null
}

variable "aws_subnet_private_name" {
  type        = string
  description = "Prefix for private subnet names"
  default     = null
}

variable "aws_subnet_service_name" {
  type        = string
  description = "Prefix for service subnet names (used for VPC endpoints)"
  default     = null
}

variable "aws_security_group_name" {
  type        = string
  description = "Name of the security group to create"
  default     = null
}

variable "aws_nat_gateway_name" {
  type        = string
  description = "Name of the NAT gateway"
  default     = null
}

variable "aws_internet_gateway_name" {
  type        = string
  description = "Name of the internet gateway"
  default     = null
}

### Network CIDRs
variable "aws_vpc_cidr" {
  type        = string
  description = "IP Range for VPC"
  default     = "10.0.0.0/16"
}

variable "aws_vpc_cidr_newbits" {
  type        = number
  description = "Number of new bits to automatically calculate the subnets mask"
  default     = 8
}

variable "aws_subnet_public_cidrs" {
  type        = list(string)
  description = "IP Ranges for public subnets"
  default     = null
}

variable "aws_subnet_private_cidrs" {
  type        = list(string)
  description = "IP Ranges for private subnets"
  default     = null
}

variable "aws_subnet_service_cidrs" {
  type        = list(string)
  description = "IP Ranges for service subnets (used for VPC endpoints)"
  default     = null
}

### Private Link
variable "enable_private_link" {
  type        = bool
  description = "Enable AWS PrivateLink for Databricks workspace?"
  default     = false
}

variable "aws_relay_service_endpoint_name" {
  type        = string
  description = "Name of the relay service VPC endpoint"
  default     = null
}

variable "aws_rest_api_endpoint_name" {
  type        = string
  description = "Name of the REST API VPC endpoint"
  default     = null
}

### Tags
variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

### Availability Zones
variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to deploy subnets in"
  default     = null
}

### Storage
variable "create_root_bucket" {
  type        = bool
  description = "Whether to create a new S3 bucket for Databricks root storage"
  default     = true
}

variable "root_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for Databricks root storage. If create_root_bucket is true, this will be used as the bucket name. If false, this should be an existing bucket name."
  default     = null
}

variable "storage_configuration_name" {
  type        = string
  description = "Name for the Databricks storage configuration"
  default     = null
}

### Metastore
variable "metastore" {
  type        = string
  description = "Metastore name to assign to the workspace. If null, no metastore will be assigned."
  default     = null
}
### General
variable "prefix" {
  type        = string
  description = "Project prefix"
  validation {
    condition = length(var.prefix) < 20
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
  description = "Pricing Tier"
  default     = "PREMIUM"
}

### Google
variable "google_project" {
  type        = string
  description = "Google Project Name"
}

variable "region" {
  type        = string
  description = "Google Region"
}

variable "google_service_account" {
  type        = string
  description = "Email of the service account used for deployment"
}

### Network Names
variable "google_vpc_name" {
  type        = string
  description = "VPC name used for deployment"
  default     = null
}

variable "create_vpc" {
  type        = bool
  description = "Terraform should create the VPC"
  default     = true
}

variable "google_subnet_name" {
  type        = string
  description = "Subnet name used for deployment"
  default     = null
}

variable "google_subnet_pods_name" {
  type        = string
  description = "Subnet name used for pods deployment"
  default     = null
}

variable "google_subnet_svc_name" {
  type        = string
  description = "Subnet name used for services deployment"
  default     = null
}

variable "google_router_name" {
  type        = string
  description = "Name of the compute router to create"
  default     = null
}

variable "google_nat_name" {
  type        = string
  description = "Name of the NAT service in compute router"
  default     = null
}

### Network CIDRs
variable "google_vpc_cidr" {
  type        = string
  description = "IP Range for VPC"
  default     = "10.0.0.0/16"
}

variable "google_vpc_cidr_newbits" {
  type        = number
  description = "Number of new bits to automatically calculate the subnets mask"
  default     = 8
}

variable "google_subnet_ip_cidr" {
  type        = string
  description = "IP Range for Nodes subnet (primary)"
  default     = null
}

variable "google_pods_ip_cidr" {
  type        = string
  description = "IP Range for Pods subnet (secondary)"
  default     = null
}

variable "google_svc_ip_cidr" {
  type        = string
  description = "IP Range for Services subnet (secondary)"
  default     = null
}

### Private Connect
variable "enable_psc" {
  type        = bool
  description = "Enable both Dataplane Relay and REST API Private Service Connect?"
  default     = null
}

variable "enable_dataplane_relay_psc" {
  type        = bool
  description = "Enable Dataplane Relay Private Service Connect?"
  default     = null
}

variable "enable_rest_api_psc" {
  type        = bool
  description = "Enable REST API Private Service Connect?"
  default     = null
}

variable "google_dataplane_relay_endpoint_vpc_name" {
  type        = string
  description = "Name of VPC Dataplane Relay Endpoint"
  default     = null
}

variable "google_dataplane_relay_endpoint_psc_name" {
  type        = string
  description = "Name of PSC Dataplane Relay Endpoint"
  default     = null
}

variable "google_dataplane_relay_endpoint_ip_name" {
  type        = string
  description = "Name of IP Dataplane Relay Endpoint"
  default     = null
}

variable "google_rest_api_endpoint_vpc_name" {
  type        = string
  description = "Name of VPC REST API Endpoint"
  default     = null
}

variable "google_rest_api_endpoint_psc_name" {
  type        = string
  description = "Name of PSC REST API Endpoint"
  default     = null
}

variable "google_rest_api_endpoint_ip_name" {
  type        = string
  description = "Name of IP REST API Endpoint"
  default     = null
}

### Metastore
variable "metastore" {
  type        = string
  description = "Metastore name to assign to the workspace. If null, no metastore will be assigned."
  default     = null
}

variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "environment_name" {
  description = "The name of the azd environment to be deployed"
  type        = string
}

variable "principal_id" {
  description = "The Id of the azd service principal to add to deployed keyvault access policies"
  type        = string
  default     = ""
}

variable "resource_group_name" {
  description = "RG for the deployment"
  type        = string
}

variable "virtual_network_name" {
  description = "The virtual network name"
  type        = string
}

variable "api_management_subnet_address_prefixes" {
  description = "The address space of the API Management subnet"
  type        = list(string)
}

variable "private_endpoint_subnet_address_prefixes" {
  description = "The address space of the private endpoint subnet"
  type        = list(string)
}

variable "public_network_access_enabled" {
  description = "Whether or not public network access is enabled"
  type        = bool
  default     = false
}

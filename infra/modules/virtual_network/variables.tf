variable "resource_group_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "tags" {
  description = "A list of tags used for deployed services."
  type        = map(string)
}

variable "resource_token" {
  description = "A suffix string to centrally mitigate resource name collisions."
  type        = string
}

variable "location" {
  description = "Location in which to deploy the network"
  type        = string
}

variable "virtual_network_name" {
  description = "VNET name"
  type        = string
}

variable "subnets" {
  description = "Subnets configuration"
  type = list(object({
    name               = string
    address_prefixes   = list(string)
    service_delegation = bool
    delegation_name    = string
    actions            = list(string)
    network_security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_ranges    = list(number)
      source_address_prefix      = string
      destination_address_prefix = string
    }))
    route_table = optional(object({
      name = string
      routes = list(object({
        name                   = string
        address_prefix         = string
        next_hop_type          = string
        next_hop_in_ip_address = string
      }))
    }))
  }))
}

variable "api_management_subnet_name" {
  description = "Specifies resource name of the subnet hosting the API Management portal."
  type        = string
}

variable "private_endpoint_subnet_name" {
  description = "Specifies resource name of the subnet hosting the private endpoints."
  type        = string
}

variable "ai_studio_subnet_name" {
  description = "Specifies resource name of the subnet hosting the AI Studio."
  type        = string
  default     = ""
}

variable "function_app_subnet_name" {
  description = "Specifies resource name of the subnet hosting the Azure Functions."
  type        = string
}

variable "subscription_id" {
  description = "The subscription id of the vNet"
  type        = string
}
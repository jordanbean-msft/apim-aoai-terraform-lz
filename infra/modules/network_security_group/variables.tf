variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

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

variable "subnet_name" {
  description = "The name of the subnet to deploy the network security group into"
  type        = string
}

variable "network_security_rules" {
  description = "The security rules to apply to the network security group"
  type = list(object({
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
}

variable "subnet_id" {
  description = "The resource id of the subnet to deploy the network security group into"
  type        = string
}

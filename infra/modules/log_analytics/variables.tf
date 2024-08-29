variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "resource_token" {
  description = "A suffix string to centrally mitigate resource name collisions."
  type        = string
}

variable "tags" {
  description = "A list of tags used for deployed services."
  type        = map(string)
}

variable "subnet_id" {
  description = "The resource id of the subnet to deploy the private endpoint into"
  type        = string
}

variable "azure_monitor_private_link_scope_name" {
  description = "The name of the private link scope for Azure Monitor"
  type        = string
}

variable "azure_monitor_private_link_scope_resource_group_name" {
  description = "The name of the resource group for the private link scope for Azure Monitor"
  type        = string
}

variable "azure_monitor_private_link_scope_subscription_id" {
  description = "The subscription id of the private link scope for Azure Monitor"
  type        = string
}
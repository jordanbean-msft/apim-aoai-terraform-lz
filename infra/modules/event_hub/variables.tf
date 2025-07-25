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
  description = "The subnet id to deploy the private endpoint into."
  type        = string
}

variable "managed_identity_principal_id" {
  description = "The principal id of the managed identity"
  type        = string
}

variable "event_hub_namespace_sku" {
  description = "The SKU of the event hub namespace"
  type        = string
}

variable "capacity" {
  description = "The capacity of the event hub namespace"
  type        = number
}

variable "maximum_throughput_units" {
  description = "The maximum throughput units of the event hub namespace"
  type        = number
}

variable "partition_count" {
  description = "The partition count of the event hub"
  type        = number
}

variable "message_retention" {
  description = "The message retention of the event hub"
  type        = number
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  type        = string
}

variable "apim_subnet_id" {
  description = "The subnet ID for the API Management service"
  type        = string
}

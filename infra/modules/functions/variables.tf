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

variable "private_endpoint_subnet_id" {
  description = "The subnet id to deploy the private endpoint into."
  type        = string
}

variable "vnet_integration_subnet_id" {
  description = "The subnet id to deploy the Azure Function into."
  type        = string
}

variable "managed_identity_principal_id" {
  description = "The principal id of the managed identity"
  type        = string
}

variable "managed_identity_id" {
  description = "The id of the managed identity"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}

variable "event_hub_namespace_fqdn" {
  description = "The fully qualified domain name of the event hub namespace"
  type        = string
}

variable "event_hub_name" {
  description = "The name of the event hub"
  type        = string
}

variable "cosmos_db_name" {
  description = "The name of the cosmos db"
  type        = string
}

variable "cosmos_db_container_name" {
  description = "The name of the cosmos db container"
  type        = string
}

variable "application_insights_connection_string" {
  description = "The connection string of the application insights"
  type        = string
}

variable "application_insights_key" {
  description = "The key of the application insights"
  type        = string
}
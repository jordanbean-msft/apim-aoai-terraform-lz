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

variable "vnet_function_subnet_id" {
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

variable "storage_account_container_name" {
  description = "The name of the function app container"
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

variable "app_settings" {
  description = "The app settings of the function app"
  type        = map(string)
}

variable "storage_account_access_key" {
  description = "The access key of the storage account"
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "The SKU of the service plan"
  type        = string
}

variable "zone_balancing_enabled" {
  description = "Enable zone balancing for the service plan"
  type        = bool
}

variable "log_analytics_workspace_id" {
  description = "The id of the Log Analytics workspace to send logs to"
  type        = string
}

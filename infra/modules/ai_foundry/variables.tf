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

variable "subnet_id" {
  description = "The resource id of the subnet to deploy the private endpoint into"
  type        = string
}

variable "user_assigned_identity_id" {
  description = "The User Assigned Managed Identity to assign to the OpenAI resources"
  type        = string
}

variable "user_assigned_identity_object_id" {
  description = "The object id of the user assigned identity"
  type        = string
}

variable "user_assigned_identity_principal_id" {
  description = "The principal id of the user assigned identity"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The id of the Log Analytics workspace to send logs to"
  type        = string
}

variable "ai_foundry_agent_subnet_resource_id" {
  description = "The resource id of the subnet to deploy the AI Foundry Agent private endpoint into"
  type        = string
}

variable "ai_foundry_sku" {
  description = "The SKU to use for the AI Foundry resource"
  type        = string
}

variable "cosmos_db_account_name" {
  description = "The name of the Cosmos DB account"
  type        = string
}

variable "cosmos_db_account_id" {
  description = "The id of the Cosmos DB account"
  type        = string
}

variable "cosmos_db_account_endpoint" {
  description = "The endpoint of the Cosmos DB account"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the Storage Account"
  type        = string
}

variable "storage_account_id" {
  description = "The id of the Storage Account"
  type        = string
}

variable "ai_search_name" {
  description = "The name of the AI Search resource"
  type        = string
}

variable "ai_search_id" {
  description = "The id of the AI Search resource"
  type        = string
}

variable "api_management_gateway_url" {
  description = "The URL of the API Management gateway"
  type        = string
}

variable "api_management_id" {
  description = "The id of the API Management resource"
  type        = string
}

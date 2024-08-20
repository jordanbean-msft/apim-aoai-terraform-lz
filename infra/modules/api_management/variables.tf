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

variable "publisher_email" {
  description = "The API Management publisher email"
  type        = string
}

variable "publisher_name" {
  description = "The API Management publisher name"
  type        = string
}

variable "sku_name" {
  description = "The API Management SKU"
  type        = string
}

variable "user_assigned_identity_id" {
  description = "The User Assigned Managed Identity to assign to the API Management portal"
  type        = string
}

variable "user_assigned_identity_client_id" {
  description = "The User Assigned Managed Identity client ID to assign to the API Management portal"
  type        = string
}

variable "api_management_subnet_id" {
  description = "The subnet ID to associate to the API Management portal"
  type        = string
}

variable "openai_endpoint" {
  description = "The OpenAI endpoint to use for the API Management service"
  type        = string
}

variable "openai_key_keyvault_secret_id" {
  description = "The OpenAI key Key Vault secret id to use for the API Management service"
  type        = string
  sensitive   = true
}

variable "cosmosdb_endpoint" {
  description = "The CosmosDB endpoint to use for the API Management service"
  type        = string
}

variable "application_insights_instrumentation_key" {
  description = "The Application Insights key to use for the API Management service"
  type        = string
  sensitive   = true
}

variable "application_insights_id" {
  description = "The Application Insights ID to use for the API Management service"
  type        = string
}

variable "key_vault_id" {
  description = "The Key Vault ID to use for the API Management service"
  type        = string
}

variable "openai_openapi_specification_url" {
  description = "The OpenAI Swagger URL to use for the API Management service"
  type        = string
}

variable "openai_token_limit_per_minute" {
  description = "The OpenAI token limit per minute to use for the API Management service"
  type        = number
}
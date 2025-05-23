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

variable "openai_endpoints" {
  description = "The OpenAI endpoints to use for the API Management service"
  type = list(object({
    key      = string
    name     = string
    endpoint = string
    priority = number
  }))
}

variable "cosmosdb_scope" {
  description = "The CosmosDB scope to use for the API Management service to authenticate using a managed identity"
  type        = string
}

variable "cosmosdb_document_endpoint" {
  description = "The CosmosDB document endpoint to use for the API Management service"
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

variable "tenant_id" {
  description = "The tenant ID to use for the API Management service"
  type        = string
}

variable "openai_service_principal_audience" {
  description = "The OpenAI service principal audience to use for the API Management service"
  type        = string
}

variable "redis_cache_id" {
  description = "The id of the Redis cache"
  type        = string
}

variable "redis_cache_name" {
  description = "The name of the Redis cache"
  type        = string
}

variable "redis_cache_connection_string" {
  description = "The connection string of the Redis cache"
  type        = string
}

variable "openai_semantic_cache_lookup_score_threshold" {
  description = "The OpenAI semantic cache lookup score threshold"
  type        = number
}

variable "openai_semantic_cache_store_duration" {
  description = "The OpenAI semantic cache store duration"
  type        = number
}

variable "openai_service_principal_client_id" {
  description = "The OpenAI service principal client ID"
  type        = string
}

variable "openai_service_id" {
  description = "The OpenAI service ID"
  type        = string
}

variable "openai_semantic_cache_embedding_backend_id" {
  description = "The OpenAI semantic cache embedding backend ID"
  type        = string
}

variable "openai_semantic_cache_embedding_backend_deployment_name" {
  description = "The OpenAI semantic cache embedding backend deployment name"
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

variable "zones" {
  description = "The availability zones to use for the API Management service"
  type        = list(string)
}

variable "log_analytics_workspace_id" {
  description = "The Log Analytics workspace ID to use for the API Management service"
  type        = string
}

variable "gemini_openapi_specification_url" {
  description = "The Google Gemini Swagger URL to use for the API Management service"
  type        = string
}

variable "gemini_api_key_kv_secret_name" {
  description = "The name of the secret in Azure Key Vault that stores the Gemini API key."
  type        = string
}

variable "gemini_backend_url" {
  description = "The backend URL for the Gemini service."
  type        = string
  default     = "" # Or a more sensible default if available
}

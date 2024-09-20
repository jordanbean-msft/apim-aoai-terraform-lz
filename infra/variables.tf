variable "location" {
  description = "The supported Azure location where the resource deployed"
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

variable "environment_name" {
  description = "The name of the environment"
  type        = string
}

variable "virtual_network_resource_group_name" {
  description = "The resource group name of the virtual network"
  type        = string
}

variable "virtual_network_name" {
  description = "The virtual network name"
  type        = string
}

variable "private_endpoint_subnet_name" {
  description = "The name of the private_endpoint subnet"
  type        = string
}

variable "private_endpoint_subnet_address_prefixes" {
  description = "The address space of the API Management subnet"
  type        = list(string)
}

variable "apim_subnet_name" {
  description = "The name of the apim subnet"
  type        = string
}

variable "apim_subnet_address_prefixes" {
  description = "The address space of the apim subnet"
  type        = list(string)
}

variable "ai_studio_subnet_name" {
  description = "The name of the AI Studio subnet"
  type        = string
}

variable "ai_studio_subnet_address_prefixes" {
  description = "The address space of the AI Studio subnet"
  type        = list(string)
}

variable "function_app_subnet_name" {
  description = "The name of the function app subnet"
  type        = string
}

variable "function_app_subnet_address_prefixes" {
  description = "The address space of the function app subnet"
  type        = list(string)
}

variable "publisher_email" {
  description = "The email address of the publisher"
  type        = string
}

variable "publisher_name" {
  description = "The name of the publisher"
  type        = string
}

variable "api_management_sku_name" {
  description = "The SKU of the API Management instance"
  type        = string
}

variable "openai_openapi_specification_url" {
  description = "The OpenAI specification URL (OpenAPI spec, Swagger document)"
  type        = string
}

variable "openai_token_limit_per_minute" {
  description = "The OpenAI token limit per minute to use for the API Management service"
  type        = number
}

variable "openai_service_principal_client_id" {
  description = "The OpenAI service principal client ID"
  type        = string
}

variable "openai_service_principal_audience" {
  description = "The OpenAI service principal audience"
  type        = string
}

variable "cosmosdb_document_time_to_live" {
  description = "The time to live for the CosmosDB data"
  type        = number
}

variable "openai_model_deployments" {
  description = "The OpenAI model deployments"
  type = list(object({
    name_suffix = string,
    kind        = string,
    sku_name    = string,
    location    = string,
    priority    = number,
    deployments = list(object({
      model = object({
        format  = string
        name    = string
        version = string
      }),
      sku = object({
        name     = string
        capacity = optional(number)
      })
    }))
    })
  )
}

variable "openai_semantic_cache_lookup_score_threshold" {
  description = "The OpenAI semantic cache lookup score threshold"
  type        = number
}

variable "openai_semantic_cache_store_duration" {
  description = "The OpenAI semantic cache store duration"
  type        = number
}

variable "redis_capacity" {
  description = "The size of the Redis cache to deploy"
  type        = number
}

variable "redis_sku_name" {
  description = "The SKU of the Redis cache to deploy"
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

variable "openai_semantic_cache_embedding_backend_deployment_name" {
  description = "The name of the OpenAI semantic cache embedding backend deployment"
  type        = string
}

variable "storage_account_tier" {
  description = "The Tier to use for this storage account"
  type        = string
}

variable "storage_account_replication_type" {
  description = "The Replication type to use for this storage account"
  type        = string
}

variable "ai_studio_sku_name" {
  description = "The AI Studio SKU"
  type        = string
}
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

variable "virtual_network_name" {
  description = "The virtual network name"
  type        = string
}

variable "api_management_subnet_address_prefixes" {
  description = "The address space of the API Management subnet"
  type        = list(string)
}

variable "private_endpoint_subnet_address_prefixes" {
  description = "The address space of the private endpoint subnet"
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

variable "openai_service_principal_audience" {
  description = "The OpenAI service principal audience"
  type        = string
}
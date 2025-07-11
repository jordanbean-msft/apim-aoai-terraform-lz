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

variable "apim" {
  type = object({
    publisher_name                                          = string
    publisher_email                                         = string
    sku_name                                                = string
    sku_capacity                                            = number
    zones                                                   = list(string)
    openai_semantic_cache_lookup_score_threshold            = number
    openai_semantic_cache_store_duration                    = number
    openai_semantic_cache_embedding_backend_deployment_name = string
    openai_openapi_specification_url                        = string
    openai_token_limit_per_minute                           = number
    openai_service_principal_client_id                      = string
    openai_service_principal_audience                       = string
    require_entra_id_authentication                         = bool
  })
}

variable "network" {
  type = object({
    virtual_network_resource_group_name      = string
    virtual_network_name                     = string
    private_endpoint_subnet_name             = string
    private_endpoint_subnet_address_prefixes = list(string)
    apim_subnet_name                         = string
    apim_subnet_address_prefixes             = list(string)
    function_app_subnet_name                 = string
    function_app_subnet_address_prefixes     = list(string)
    firewall_ip_address                      = optional(string)
  })
}

variable "cosmos_db" {
  type = object({
    document_time_to_live = number
    max_throughput        = number
    zone_redundant        = bool
  })
}

variable "openai" {
  type = object({
    pools = list(object({
      name    = string
      default = bool
      instances = list(
        object({
          name_suffix = string
          kind        = string
          sku_name    = string
          location    = string
          priority    = number
          deployments = list(object({
            model = object({
              format  = string
              name    = string
              version = string
            }),
            sku = object({
              name     = string
              capacity = optional(number)
            }),
            rai_policy_name = string
          }))
      }))
    }))
  })
}

variable "redis" {
  type = object({
    shouldDeployRedis = bool
    capacity          = number
    sku_name          = string
    zones             = list(string)
  })
}

variable "storage_account" {
  type = object({
    tier             = string
    replication_type = string
  })
}

variable "event_hub" {
  type = object({
    namespace_sku            = string
    capacity                 = number
    maximum_throughput_units = number
    partition_count          = number
    message_retention        = number
  })
}

variable "function_app" {
  type = object({
    sku_name               = string
    zone_balancing_enabled = bool
  })
}

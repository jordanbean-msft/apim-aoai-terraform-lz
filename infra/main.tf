locals {
  tags                                           = { azd-env-name : var.environment_name }
  sha                                            = base64encode(sha256("${var.location}${data.azurerm_client_config.current.subscription_id}"))
  resource_token                                 = substr(replace(lower(local.sha), "[^A-Za-z0-9_]", ""), 0, 13)
  azure_openai_secret_name                       = "azure-openai-key"
  cosmosdb_account_connection_string_secret_name = "cosmosdb-account-connection-string"
  api_management_subnet_nsg_name                 = "nsg-${var.network.apim_subnet_name}-subnet"
  private_endpoint_subnet_nsg_name               = "nsg-${var.network.private_endpoint_subnet_name}-subnet"
  function_app_subnet_nsg_name                   = "nsg-${var.network.function_app_subnet_name}-subnet"
  openai_service_principal_client_secret_name    = "openai-service-principal-client-secret"
}

# ------------------------------------------------------------------------------------------------------
# Deploy virtual network
# ------------------------------------------------------------------------------------------------------

module "virtual_network" {
  source               = "./modules/virtual_network"
  location             = var.location
  resource_group_name  = var.network.virtual_network_resource_group_name
  tags                 = local.tags
  resource_token       = local.resource_token
  virtual_network_name = var.network.virtual_network_name
  subnets = [
    {
      name                   = var.network.apim_subnet_name
      address_prefixes       = var.network.apim_subnet_address_prefixes
      service_delegation     = false
      delegation_name        = "Microsoft.Web/serverFarms"
      actions                = []
      network_security_rules = []
    },
    {
      name                   = var.network.private_endpoint_subnet_name
      address_prefixes       = var.network.private_endpoint_subnet_address_prefixes
      service_delegation     = false
      delegation_name        = ""
      actions                = []
      network_security_rules = []
    },
    {
      name                   = var.network.function_app_subnet_name
      address_prefixes       = var.network.function_app_subnet_address_prefixes
      service_delegation     = false
      delegation_name        = "Microsoft.Web/serverFarms"
      actions                = []
      network_security_rules = []
    }
  ]
  api_management_subnet_name   = var.network.apim_subnet_name
  private_endpoint_subnet_name = var.network.private_endpoint_subnet_name
  function_app_subnet_name     = var.network.function_app_subnet_name
  subscription_id              = data.azurerm_client_config.current.subscription_id
  firewall_ip_address          = var.network.firewall_ip_address
}

# ------------------------------------------------------------------------------------------------------
# Deploy application insights
# ------------------------------------------------------------------------------------------------------
module "application_insights" {
  source              = "./modules/application_insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = module.log_analytics.log_analytics_workspace_id
  tags                = local.tags
  resource_token      = local.resource_token
}

# ------------------------------------------------------------------------------------------------------
# Deploy Azure Monitor workbook
# ------------------------------------------------------------------------------------------------------
module "workbook" {
  source              = "./modules/workbook"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  resource_token      = local.resource_token
}

# ------------------------------------------------------------------------------------------------------
# Deploy log analytics
# ------------------------------------------------------------------------------------------------------
module "log_analytics" {
  source              = "./modules/log_analytics"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  resource_token      = local.resource_token
}

# ------------------------------------------------------------------------------------------------------
# Deploy managed identity
# ------------------------------------------------------------------------------------------------------
module "managed_identity" {
  source              = "./modules/managed_identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  resource_token      = local.resource_token
}

# ------------------------------------------------------------------------------------------------------
# Deploy key vault
# ------------------------------------------------------------------------------------------------------
module "key_vault" {
  source              = "./modules/key_vault"
  location            = var.location
  principal_id        = var.principal_id
  resource_group_name = var.resource_group_name
  tags                = local.tags
  resource_token      = local.resource_token
  access_policy_object_ids = [
    module.managed_identity.user_assigned_identity_object_id
  ]
  secrets = [
  ]
  subnet_id                                   = module.virtual_network.private_endpoint_subnet_id
  openai_service_principal_client_secret_name = local.openai_service_principal_client_secret_name
  log_analytics_workspace_id                  = module.log_analytics.log_analytics_workspace_id
}

# ------------------------------------------------------------------------------------------------------
# Deploy OpenAI
# ------------------------------------------------------------------------------------------------------
module "openai" {
  source                              = "./modules/open_ai"
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  resource_token                      = local.resource_token
  tags                                = local.tags
  subnet_id                           = module.virtual_network.private_endpoint_subnet_id
  user_assigned_identity_object_id    = module.managed_identity.user_assigned_identity_object_id
  openai_model_deployments            = var.openai
  log_analytics_workspace_id          = module.log_analytics.log_analytics_workspace_id
  user_assigned_identity_id           = module.managed_identity.user_assigned_identity_id
  user_assigned_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
}

# ------------------------------------------------------------------------------------------------------
# Deploy CosmosDB
# ------------------------------------------------------------------------------------------------------
module "cosmosdb" {
  source                              = "./modules/cosmosdb"
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  resource_token                      = local.resource_token
  tags                                = local.tags
  subnet_id                           = module.virtual_network.private_endpoint_subnet_id
  user_assigned_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
  subscription_id                     = data.azurerm_client_config.current.subscription_id
  principal_id                        = var.principal_id
  document_time_to_live               = var.cosmos_db.document_time_to_live
  max_throughput                      = var.cosmos_db.max_throughput
  zone_redundant                      = var.cosmos_db.zone_redundant
  log_analytics_workspace_id          = module.log_analytics.log_analytics_workspace_id
}

# ------------------------------------------------------------------------------------------------------
# Deploy API Management
# ------------------------------------------------------------------------------------------------------
module "api_management" {
  source                                                  = "./modules/api_management"
  location                                                = var.location
  resource_group_name                                     = var.resource_group_name
  resource_token                                          = local.resource_token
  tags                                                    = local.tags
  api_management_subnet_id                                = module.virtual_network.api_management_subnet_id
  user_assigned_identity_id                               = module.managed_identity.user_assigned_identity_id
  user_assigned_identity_client_id                        = module.managed_identity.user_assigned_identity_client_id
  user_assigned_identity_principal_id                     = module.managed_identity.user_assigned_identity_principal_id
  publisher_name                                          = var.apim.publisher_name
  publisher_email                                         = var.apim.publisher_email
  sku_name                                                = var.apim.sku_name
  sku_capacity                                            = var.apim.sku_capacity
  application_insights_id                                 = module.application_insights.application_insights_id
  openai_endpoints                                        = module.openai.azure_cognitive_services_endpoints
  key_vault_id                                            = module.key_vault.key_vault_id
  cosmosdb_scope                                          = "https://${module.cosmosdb.cosmosdb_account_name}.documents.azure.com"
  cosmosdb_document_endpoint                              = "${module.cosmosdb.cosmosdb_account_endpoint}dbs/${module.cosmosdb.cosmosdb_sql_database_name}/colls/${module.cosmosdb.cosmosdb_sql_container_name}/docs"
  application_insights_instrumentation_key                = module.application_insights.application_insights_instrumentation_key
  openai_openapi_specification_url                        = var.apim.openai_openapi_specification_url
  openai_token_limit_per_minute                           = var.apim.openai_token_limit_per_minute
  tenant_id                                               = data.azurerm_client_config.current.tenant_id
  openai_service_principal_audience                       = var.apim.openai_service_principal_audience
  redis_cache_connection_string                           = null
  redis_cache_name                                        = null
  redis_cache_id                                          = null
  openai_semantic_cache_lookup_score_threshold            = var.apim.openai_semantic_cache_lookup_score_threshold
  openai_semantic_cache_store_duration                    = var.apim.openai_semantic_cache_store_duration
  openai_service_principal_client_id                      = var.apim.openai_service_principal_client_id
  openai_service_id                                       = module.openai.azure_cognitive_services_ids[0]
  openai_service_name                                     = module.openai.azure_cognitive_services_names[0]
  openai_semantic_cache_embedding_backend_id              = "openai-semantic-cache-embedding-backend-id"
  openai_semantic_cache_embedding_backend_deployment_name = var.apim.openai_semantic_cache_embedding_backend_deployment_name
  event_hub_namespace_fqdn                                = module.event_hub.event_hub_namespace_fqdn
  event_hub_name                                          = module.event_hub.event_hub_central_name
  zones                                                   = var.apim.zones
  log_analytics_workspace_id                              = module.log_analytics.log_analytics_workspace_id
  subscription_id                                         = data.azurerm_client_config.current.subscription_id
  openai                                                  = var.openai
  use_semantic_caching                                    = var.redis.shouldDeployRedis
  private_endpoint_subnet_id                              = module.virtual_network.private_endpoint_subnet_id
  require_entra_id_authentication                         = var.apim.require_entra_id_authentication
}

# ------------------------------------------------------------------------------------------------------
# Deploy Redis Cache
# ------------------------------------------------------------------------------------------------------
module "redis" {
  count                            = var.redis.shouldDeployRedis ? 1 : 0
  source                           = "./modules/redis"
  location                         = var.location
  resource_group_name              = var.resource_group_name
  tags                             = local.tags
  resource_token                   = local.resource_token
  subnet_id                        = module.virtual_network.private_endpoint_subnet_id
  user_assigned_identity_name      = module.managed_identity.user_assigned_identity_name
  user_assigned_identity_object_id = module.managed_identity.user_assigned_identity_object_id
  capacity                         = var.redis.capacity
  sku_name                         = var.redis.sku_name
  zones                            = var.redis.zones
  log_analytics_workspace_id       = module.log_analytics.log_analytics_workspace_id
}

# ------------------------------------------------------------------------------------------------------
# Deploy Storage Account
# ------------------------------------------------------------------------------------------------------

module "storage_account" {
  source                        = "./modules/storage_account"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = local.tags
  resource_token                = local.resource_token
  subnet_id                     = module.virtual_network.private_endpoint_subnet_id
  account_tier                  = var.storage_account.tier
  account_replication_type      = var.storage_account.replication_type
  managed_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
  log_analytics_workspace_id    = module.log_analytics.log_analytics_workspace_id
}

# ------------------------------------------------------------------------------------------------------
# Deploy Event Hub
# ------------------------------------------------------------------------------------------------------

module "event_hub" {
  source                        = "./modules/event_hub"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = local.tags
  resource_token                = local.resource_token
  subnet_id                     = module.virtual_network.private_endpoint_subnet_id
  managed_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
  event_hub_namespace_sku       = var.event_hub.namespace_sku
  capacity                      = var.event_hub.capacity
  maximum_throughput_units      = var.event_hub.maximum_throughput_units
  partition_count               = var.event_hub.partition_count
  message_retention             = var.event_hub.message_retention
  log_analytics_workspace_id    = module.log_analytics.log_analytics_workspace_id
  apim_subnet_id                = module.virtual_network.api_management_subnet_id
}

# ------------------------------------------------------------------------------------------------------
# Deploy Azure Function
# ------------------------------------------------------------------------------------------------------

module "functions" {
  source                                 = "./modules/functions"
  location                               = var.location
  resource_group_name                    = var.resource_group_name
  tags                                   = local.tags
  resource_token                         = local.resource_token
  private_endpoint_subnet_id             = module.virtual_network.private_endpoint_subnet_id
  vnet_function_subnet_id                = module.virtual_network.function_app_subnet_id
  managed_identity_principal_id          = module.managed_identity.user_assigned_identity_principal_id
  managed_identity_id                    = module.managed_identity.user_assigned_identity_id
  storage_account_name                   = module.storage_account.storage_account_name
  storage_account_container_name         = module.storage_account.function_app_container_name
  application_insights_connection_string = module.application_insights.application_insights_connection_string
  application_insights_key               = module.application_insights.application_insights_instrumentation_key
  storage_account_access_key             = module.storage_account.storage_account_access_key
  app_settings = {
    "EVENT_HUB__fullyQualifiedNamespace" = module.event_hub.event_hub_namespace_fqdn
    "EVENT_HUB_CENTRAL_NAME"             = module.event_hub.event_hub_central_name
    "EVENT_HUB_LLM_LOGGING_NAME"         = module.event_hub.event_hub_llm_logging_name
    "EVENT_HUB__credential"              = "managedidentity"
    "EVENT_HUB__clientId"                = module.managed_identity.user_assigned_identity_client_id
    "COSMOS_DB__credential"              = "managedidentity"
    "COSMOS_DB__clientId"                = module.managed_identity.user_assigned_identity_client_id
    "COSMOS_DB__accountEndpoint"         = module.cosmosdb.cosmosdb_account_endpoint
    "COSMOS_DB_NAME"                     = module.cosmosdb.cosmosdb_sql_database_name
    "COSMOS_DB_CONTAINER_NAME"           = module.cosmosdb.cosmosdb_sql_container_name
    "AzureWebJobsStorage__accountName"   = module.storage_account.storage_account_name
    "AzureWebJobsStorage__credential"    = "managedidentity"
    "AzureWebJobsStorage__clientId"      = module.managed_identity.user_assigned_identity_client_id
    "AZURE_CLIENT_ID"                    = module.managed_identity.user_assigned_identity_client_id
  }
  sku_name                   = var.function_app.sku_name
  zone_balancing_enabled     = var.function_app.zone_balancing_enabled
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
}

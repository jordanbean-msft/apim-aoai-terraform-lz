locals {
  tags                                           = {}
  sha                                            = base64encode(sha256("${var.location}${data.azurerm_client_config.current.subscription_id}"))
  resource_token                                 = substr(replace(lower(local.sha), "[^A-Za-z0-9_]", ""), 0, 13)
  azure_openai_secret_name                       = "azure-openai-key"
  cosmosdb_account_connection_string_secret_name = "cosmosdb-account-connection-string"
  api_management_subnet_nsg_name                 = "nsg-${var.integration_subnet_name}-subnet"
  private_endpoint_subnet_nsg_name               = "nsg-${var.application_subnet_name}-subnet"
  openai_service_principal_client_secret_name    = "openai-service-principal-client-secret"
}

# ------------------------------------------------------------------------------------------------------
# Deploy virtual network
# ------------------------------------------------------------------------------------------------------

module "virtual_network" {
  source               = "./modules/virtual_network"
  location             = var.location
  resource_group_name  = var.virtual_network_resource_group_name
  tags                 = local.tags
  resource_token       = local.resource_token
  virtual_network_name = var.virtual_network_name
  subnets = [
    {
      name               = var.integration_subnet_name
      address_prefixes   = var.integration_subnet_address_prefixes
      service_delegation = false
      delegation_name    = ""
      actions            = [""]
      network_security_rules = [
        {
          name                       = "AllowManagementEndpointForAzurePortalAndPowerShell"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = [3443]
          source_address_prefix      = "Internet"
          destination_address_prefix = "VirtualNetwork"
        },
        {
          name                       = "AllowAzureInfrastructureLoadBalancer"
          priority                   = 130
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = [6390]
          source_address_prefix      = "ApiManagement"
          destination_address_prefix = "VirtualNetwork"
        },
        {
          name                       = "AllowDependencyOnAzureStorageForCoreServiceFunctionality"
          priority                   = 120
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = [443]
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "Storage"
        },
        {
          name                       = "AllowAccessToAzureSQLEndpointsForCoreServiceFunctionality"
          priority                   = 130
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = [1433]
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "SQL"
        },
        {
          name                       = "AllowAccessToAzureKeyVaultForCoreServiceFunctionality"
          priority                   = 140
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = [443]
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "AzureKeyVault"
        },
        {
          name                       = "AllowPublishDiagnosticLogsAndMetricsResourceHealthAndApplicationInsights"
          priority                   = 150
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = [1886, 443]
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "AzureMonitor"
        }
      ]
    },
    {
      name                   = var.application_subnet_name
      address_prefixes       = var.application_subnet_address_prefixes
      service_delegation     = false
      delegation_name        = ""
      actions                = []
      network_security_rules = []
    }
  ]
  api_management_subnet_name   = var.integration_subnet_name
  private_endpoint_subnet_name = var.application_subnet_name
  subscription_id              = data.azurerm_client_config.current.subscription_id
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
# Deploy log analytics
# ------------------------------------------------------------------------------------------------------
module "log_analytics" {
  source                                               = "./modules/log_analytics"
  location                                             = var.location
  resource_group_name                                  = var.resource_group_name
  tags                                                 = local.tags
  resource_token                                       = local.resource_token
  azure_monitor_private_link_scope_name                = var.azure_monitor_private_link_scope_name
  azure_monitor_private_link_scope_resource_group_name = var.azure_monitor_private_link_scope_resource_group_name
  subnet_id                                            = module.virtual_network.private_endpoint_subnet_id
  azure_monitor_private_link_scope_subscription_id     = var.azure_monitor_private_link_scope_subscription_id
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
}

# ------------------------------------------------------------------------------------------------------
# Deploy OpenAI
# ------------------------------------------------------------------------------------------------------
module "openai" {
  source                           = "./modules/open_ai"
  location                         = var.location
  resource_group_name              = var.resource_group_name
  resource_token                   = local.resource_token
  tags                             = local.tags
  subnet_id                        = module.virtual_network.private_endpoint_subnet_id
  user_assigned_identity_object_id = module.managed_identity.user_assigned_identity_object_id
  openai_model_deployments         = var.openai_model_deployments
}

# ------------------------------------------------------------------------------------------------------
# Deploy CosmosDB
# ------------------------------------------------------------------------------------------------------
module "cosmosdb" {
  source                           = "./modules/cosmosdb"
  location                         = var.location
  resource_group_name              = var.resource_group_name
  resource_token                   = local.resource_token
  tags                             = local.tags
  subnet_id                        = module.virtual_network.private_endpoint_subnet_id
  user_assigned_identity_object_id = module.managed_identity.user_assigned_identity_object_id
  subscription_id                  = data.azurerm_client_config.current.subscription_id
  principal_id                     = var.principal_id
  cosmosdb_document_time_to_live   = var.cosmosdb_document_time_to_live
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
  publisher_name                                          = var.publisher_name
  publisher_email                                         = var.publisher_email
  sku_name                                                = var.api_management_sku_name
  application_insights_id                                 = module.application_insights.application_insights_id
  openai_endpoints                                        = module.openai.azure_cognitive_services_endpoints
  key_vault_id                                            = module.key_vault.key_vault_id
  cosmosdb_scope                                          = "https://${module.cosmosdb.cosmosdb_account_name}.documents.azure.com"
  cosmosdb_document_endpoint                              = "${module.cosmosdb.cosmosdb_account_endpoint}dbs/${module.cosmosdb.cosmosdb_sql_database_name}/colls/${module.cosmosdb.cosmosdb_sql_container_name}/docs"
  application_insights_instrumentation_key                = module.application_insights.application_insights_instrumentation_key
  openai_openapi_specification_url                        = var.openai_openapi_specification_url
  openai_token_limit_per_minute                           = var.openai_token_limit_per_minute
  tenant_id                                               = data.azurerm_client_config.current.tenant_id
  openai_service_principal_audience                       = var.openai_service_principal_audience
  redis_cache_connection_string                           = "" #module.redis.redis_cache_primary_connection_string
  redis_cache_name                                        = "" #module.redis.redis_cache_name
  redis_cache_id                                          = "" #module.redis.redis_cache_id
  openai_semantic_cache_lookup_score_threshold            = var.openai_semantic_cache_lookup_score_threshold
  openai_semantic_cache_store_duration                    = var.openai_semantic_cache_store_duration
  openai_service_principal_client_id                      = var.openai_service_principal_client_id
  openai_service_id                                       = module.openai.azure_cognitive_services_ids[0]
  openai_semantic_cache_embedding_backend_id              = "openai-semantic-cache-embedding-backend-id"
  openai_semantic_cache_embedding_backend_deployment_name = var.openai_semantic_cache_embedding_backend_deployment_name
}

# ------------------------------------------------------------------------------------------------------
# Deploy Redis Cache
# ------------------------------------------------------------------------------------------------------
# module "redis" {
#   source                           = "./modules/redis"
#   location                         = var.location
#   resource_group_name              = var.resource_group_name
#   tags                             = local.tags
#   resource_token                   = local.resource_token
#   subnet_id                        = module.virtual_network.private_endpoint_subnet_id
#   user_assigned_identity_name      = module.managed_identity.user_assigned_identity_name
#   user_assigned_identity_object_id = module.managed_identity.user_assigned_identity_object_id
#   capacity                         = var.redis_capacity
#   sku_name                         = var.redis_sku_name
# }

# ------------------------------------------------------------------------------------------------------
# Deploy Storage Account
# ------------------------------------------------------------------------------------------------------

module "storage_account" {
  source                           = "./modules/storage_account"
  location                         = var.location
  resource_group_name              = var.resource_group_name
  tags                             = local.tags
  resource_token                   = local.resource_token
  subnet_id                        = module.virtual_network.private_endpoint_subnet_id
  account_tier                     = var.storage_account_tier
  account_replication_type         = var.storage_account_replication_type
}

# ------------------------------------------------------------------------------------------------------
# Deploy Container Registry
# ------------------------------------------------------------------------------------------------------

module "container_registry" {
  source                        = "./modules/container_registry"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = local.tags
  resource_token                = local.resource_token
  subnet_id                     = module.virtual_network.private_endpoint_subnet_id
  managed_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
}

# ------------------------------------------------------------------------------------------------------
# Deploy AI Studio
# ------------------------------------------------------------------------------------------------------

module "ai_studio" {
  source                  = "./modules/ai_studio"
  location                = var.location
  resource_group_name     = var.resource_group_name
  tags                    = local.tags
  resource_token          = local.resource_token
  subnet_id               = module.virtual_network.private_endpoint_subnet_id
  sku                     = var.ai_studio_sku_name
  application_insights_id = module.application_insights.application_insights_id
  key_vault_id            = module.key_vault.key_vault_id
  storage_account_id      = module.storage_account.storage_account_id
  container_registry_id   = module.container_registry.container_registry_id
  resource_group_id       = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
}
locals {
  tags                                           = {}
  sha                                            = base64encode(sha256("${var.location}${data.azurerm_client_config.current.subscription_id}"))
  resource_token                                 = substr(replace(lower(local.sha), "[^A-Za-z0-9_]", ""), 0, 13)
  azure_openai_secret_name                       = "azure-openai-key"
  cosmosdb_account_connection_string_secret_name = "cosmosdb-account-connection-string"
  api_management_subnet_name                     = "api-management-subnet"
  api_management_subnet_nsg_name                 = "nsg-api-management-subnet"
  private_endpoint_subnet_name                   = "private-endpoint-subnet"
  private_endpoint_subnet_nsg_name               = "nsg-private-endpoint-subnet"
}

# ------------------------------------------------------------------------------------------------------
# Deploy virtual network
# ------------------------------------------------------------------------------------------------------

module "virtual_network" {
  source               = "./modules/virtual_network"
  location             = var.location
  resource_group_name  = var.resource_group_name
  tags                 = local.tags
  resource_token       = local.resource_token
  virtual_network_name = var.virtual_network_name
  subnets = [
    {
      name               = local.api_management_subnet_name
      address_prefixes   = var.api_management_subnet_address_prefixes
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
      name                   = local.private_endpoint_subnet_name
      address_prefixes       = var.private_endpoint_subnet_address_prefixes
      service_delegation     = false
      delegation_name        = ""
      actions                = []
      network_security_rules = []
    }
  ]
  api_management_subnet_name   = local.api_management_subnet_name
  private_endpoint_subnet_name = local.private_endpoint_subnet_name
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
    {
      name  = local.azure_openai_secret_name
      value = module.openai.azure_cognitive_services_key
    },
    {
      name  = local.cosmosdb_account_connection_string_secret_name
      value = module.cosmosdb.cosmosdb_account_connection_string
    }
  ]
  subnet_id = module.virtual_network.private_endpoint_subnet_id
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
}

# ------------------------------------------------------------------------------------------------------
# Deploy API Management
# ------------------------------------------------------------------------------------------------------
module "api_management" {
  source                                   = "./modules/api_management"
  location                                 = var.location
  resource_group_name                      = var.resource_group_name
  resource_token                           = local.resource_token
  tags                                     = local.tags
  api_management_subnet_id                 = module.virtual_network.api_management_subnet_id
  user_assigned_identity_id                = module.managed_identity.user_assigned_identity_id
  user_assigned_identity_client_id         = module.managed_identity.user_assigned_identity_client_id
  publisher_name                           = var.publisher_name
  publisher_email                          = var.publisher_email
  sku_name                                 = var.api_management_sku_name
  application_insights_id                  = module.application_insights.application_insights_id
  openai_endpoint                          = module.openai.azure_cognitive_services_endpoint
  key_vault_id                             = module.key_vault.key_vault_id
  cosmosdb_scope                           = "https://${module.cosmosdb.cosmosdb_account_name}.documents.azure.com"
  cosmosdb_document_endpoint               = "${module.cosmosdb.cosmosdb_account_endpoint}dbs/${module.cosmosdb.cosmosdb_sql_database_name}/colls/${module.cosmosdb.cosmosdb_sql_container_name}/docs"
  application_insights_instrumentation_key = module.application_insights.application_insights_instrumentation_key
  openai_key_keyvault_secret_id            = "https://${module.key_vault.key_vault_name}.vault.azure.net/secrets/${local.azure_openai_secret_name}"
  openai_openapi_specification_url         = var.openai_openapi_specification_url
  openai_token_limit_per_minute            = var.openai_token_limit_per_minute
  tenant_id                                = data.azurerm_client_config.current.tenant_id
  openai_service_principal_audience        = var.openai_service_principal_audience
}
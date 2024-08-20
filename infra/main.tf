locals {
  tags                                 = { azd-env-name : var.environment_name }
  sha                                  = base64encode(sha256("${var.environment_name}${var.location}${data.azurerm_client_config.current.subscription_id}"))
  resource_token                       = substr(replace(lower(local.sha), "[^A-Za-z0-9_]", ""), 0, 13)
  azure_openai_secret_name             = "azure-openai-key"
  azure_cognitive_services_secret_name = "azure-cognitive-services-key"
  api_management_subnet_name           = "container-app-subnet"
  api_management_subnet_nsg_name       = "nsg-container-app-subnet"
  private_endpoint_subnet_name         = "private-endpoint-subnet"
  private_endpoint_subnet_nsg_name     = "nsg-private-endpoint-subnet"
  api_version                          = "v1"
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
      name                   = local.api_management_subnet_name
      address_prefixes       = var.api_management_subnet_address_prefixes
      service_delegation     = true
      delegation_name        = ""
      actions                = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      network_security_rules = []
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
  environment_name    = var.environment_name
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
      name  = local.azure_cognitive_services_secret_name
      value = module.document_intelligence.azure_cognitive_services_key
    },
  ]
  subnet_id                     = module.virtual_network.private_endpoint_subnet_id
  private_dns_zone_group_ids    = [module.dns_zones.key_vault_dns_zone_id]
  public_network_access_enabled = var.public_network_access_enabled
}

# ------------------------------------------------------------------------------------------------------
# Deploy OpenAI
# ------------------------------------------------------------------------------------------------------
module "openai" {
  source                        = "./modules/open_ai"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  resource_token                = local.resource_token
  tags                          = local.tags
  subnet_id                     = module.virtual_network.private_endpoint_subnet_id
  private_dns_zone_group_ids    = [module.dns_zones.openai_dns_zone_id]
  public_network_access_enabled = var.public_network_access_enabled
}

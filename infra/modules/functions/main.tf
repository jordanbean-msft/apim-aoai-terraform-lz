terraform {
  required_providers {
    azurerm = {
      version = "~>4.0.1"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.28"
    }
  }
}
# ------------------------------------------------------------------------------------------------------
# Deploy Azure Function
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "service_plan_name" {
  name          = var.resource_token
  resource_type = "azurerm_app_service_plan"
  random_length = 0
  clean_input   = true
}

resource "azurerm_service_plan" "service_plan" {
  name                = azurecaf_name.service_plan_name.result
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "EP1"
  tags                = var.tags
}

resource "azurecaf_name" "function_name" {
  name          = var.resource_token
  resource_type = "azurerm_function_app"
  random_length = 0
  clean_input   = true
}

resource "azurerm_linux_function_app" "function_app" {
  name                = azurecaf_name.function_name.result
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, { "azd-service-name" = "write-to-cosmos" })
  service_plan_id     = azurerm_service_plan.service_plan.id
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }
  key_vault_reference_identity_id = var.managed_identity_id
  storage_uses_managed_identity   = true
  virtual_network_subnet_id       = var.vnet_integration_subnet_id
  storage_account_name            = var.storage_account_name
  public_network_access_enabled = false
  site_config {
    application_insights_connection_string = var.application_insights_connection_string
    application_insights_key               = var.application_insights_key
    application_stack {
      python_version = 3.12
    }
    ip_restriction_default_action = "Deny"
  }
  app_settings = {
    "EVENT_HUB__fullyQualifiedNamespace" = var.event_hub_namespace_fqdn
    "EVENT_HUB_NAME"                     = var.event_hub_name
    "EVENT_HUB__credential"              = "managedIdentity"
    "EVENT_HUB__clientId"                = var.managed_identity_principal_id
    "COSMOS_DB__credential"              = "managedIdentity"
    "COSMOS_DB__clientId"                = var.managed_identity_principal_id
    "COSMOS_DB_NAME"                     = var.cosmos_db_name
    "COSMOS_DB_CONTAINER_NAME"           = var.cosmos_db_container_name
  }
}

module "private_endpoint" {
  source                         = "../private_endpoint"
  name                           = azurerm_linux_function_app.function_app.name
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azurerm_linux_function_app.function_app.id
  location                       = var.location
  subnet_id                      = var.private_endpoint_subnet_id
  subresource_names              = ["sites"]
  is_manual_connection           = false
}
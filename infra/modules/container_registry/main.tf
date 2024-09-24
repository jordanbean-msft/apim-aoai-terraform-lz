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
# Deploy API Management
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "api_management_name" {
  name          = var.resource_token
  resource_type = "azurerm_container_registry"
  random_length = 0
  clean_input   = true
}

resource "azurerm_container_registry" "container_registry" {
  name                          = azurecaf_name.api_management_name.result
  location                      = var.location
  tags                          = var.tags
  resource_group_name           = var.resource_group_name
  sku                           = "Premium"
  admin_enabled                 = true
  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"
}

resource "azurerm_role_assignment" "managed_identity_acr_role" {
  scope                = azurerm_container_registry.container_registry.id
  role_definition_name = "AcrPull"
  principal_id         = var.managed_identity_principal_id
}

module "private_endpoint" {
  source                         = "../private_endpoint"
  name                           = azurerm_container_registry.container_registry.name
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azurerm_container_registry.container_registry.id
  location                       = var.location
  subnet_id                      = var.subnet_id
  subresource_names              = ["registry"]
  is_manual_connection           = false
}
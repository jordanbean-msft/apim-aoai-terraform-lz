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
# Deploy log analytics workspace
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "api_management_name" {
  name          = var.resource_token
  resource_type = "azurerm_api_management"
  random_length = 0
  clean_input   = true
}

resource "azurerm_api_management" "api_management" {
  name                = "${azurecaf_name.api_management_name.result}-001"
  location            = var.location
  tags                = var.tags
  resource_group_name = var.resource_group_name
  publisher_email     = var.publisher_email
  publisher_name      = var.publisher_name
  sku_name            = var.sku_name
  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }
  virtual_network_type = "Internal"
  virtual_network_configuration {
    subnet_id = var.api_management_subnet_id
  }
}

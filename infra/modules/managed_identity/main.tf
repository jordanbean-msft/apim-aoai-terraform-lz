terraform {
  required_providers {
    azurerm = {
      version = "~>3.105.0"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.28"
    }
  }
}
# ------------------------------------------------------------------------------------------------------
# Deploy managed identity
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "workspace_name" {
  name          = var.resource_token
  resource_type = "azurerm_user_assigned_identity"
  random_length = 0
  clean_input   = true
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = azurecaf_name.workspace_name.result
  location            = var.location
  tags                = var.tags
  resource_group_name = var.resource_group_name
}
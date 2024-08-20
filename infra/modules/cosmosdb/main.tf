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
# Deploy log analytics workspace
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "cosmosdb_account_name" {
  name          = var.resource_token
  resource_type = "azurerm_cosmosdb_account"
  random_length = 0
  clean_input   = true
}

resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                                  = azurecaf_name.cosmosdb_account_name.result
  location                              = var.location
  tags                                  = var.tags
  resource_group_name                   = var.resource_group_name
  public_network_access_enabled         = false
  network_acl_bypass_for_azure_services = true
  local_authentication_disabled         = true
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    location          = var.location
    failover_priority = 0
  }
  offer_type = "Standard"
  capabilities {
    name = "DeleteAllItemsByPartitionKey"
  }
}
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
# DEPLOY PRIVATE ENDPOINT
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "route_table_name" {
  name          = "${var.name}-${var.resource_token}"
  resource_type = "azurerm_route_table"
  random_length = 0
  clean_input   = true
}

resource "azurerm_route_table" "route_table" {
  name                = azurecaf_name.route_table_name.result
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  route = var.routes
}
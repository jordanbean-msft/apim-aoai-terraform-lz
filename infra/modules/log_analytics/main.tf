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
resource "azurecaf_name" "workspace_name" {
  name          = var.resource_token
  resource_type = "azurerm_log_analytics_workspace"
  random_length = 0
  clean_input   = true
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                       = azurecaf_name.workspace_name.result
  location                   = var.location
  resource_group_name        = var.resource_group_name
  sku                        = "PerGB2018"
  retention_in_days          = 30
  tags                       = var.tags
  internet_ingestion_enabled = false
  internet_query_enabled     = false
}

module "private_endpoint" {
  source                         = "../private_endpoint"
  name                           = "azure_monitor_private_link_service"
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = "/subscriptions/${var.azure_monitor_private_link_scope_subscription_id}/resourceGroups/${var.azure_monitor_private_link_scope_resource_group_name}/providers/Microsoft.Insights/privateLinkScopes/${var.azure_monitor_private_link_scope_name}"
  location                       = var.location
  subnet_id                      = var.subnet_id
  subresource_names              = ["azuremonitor"]
  is_manual_connection           = false
}
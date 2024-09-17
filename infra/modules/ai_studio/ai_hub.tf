// Azure AI Hub
resource "azapi_resource" "ai_hub" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-04-01-preview"
  name      = "aih-${var.resource_token}"
  location  = var.location
  parent_id = var.resource_group_id

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      description         = "Central AI Studio Hub"
      friendlyName        = "Central AI Studio Hub"
      storageAccount      = var.storage_account_id
      keyVault            = var.key_vault_id
      applicationInsights = var.application_insights_id
      containerRegistry   = var.container_registry_id
      managedNetwork = {
        isolationMode = "AllowOnlyApprovedOutbound"
      }
      publicNetworkAccess = "Disabled"
    }
    kind = "Hub"
  })
}

module "private_endpoint_ai_hub" {
  source                         = "../private_endpoint"
  name                           = azapi_resource.ai_hub.name
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azapi_resource.ai_hub.id
  location                       = var.location
  subnet_id                      = var.subnet_id
  subresource_names              = ["amlworkspace"]
  is_manual_connection           = false
}
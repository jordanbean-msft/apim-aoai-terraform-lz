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
    azapi = {
      source  = "Azure/azapi"
      version = "2.3.0"
    }
  }
}
# ------------------------------------------------------------------------------------------------------
# Deploy AI Studio
# ------------------------------------------------------------------------------------------------------

// AzAPI AIServices
resource "azapi_resource" "ai_services_resource" {
  type      = "Microsoft.CognitiveServices/accounts@2023-10-01-preview"
  name      = "ais-${var.resource_token}"
  location  = var.location
  parent_id = var.resource_group_id
  tags      = var.tags

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    name = "ais-${var.resource_token}"
    properties = {
      //restore = true
      customSubDomainName = "ais-${var.resource_token}-domain"
      apiProperties = {
        statisticsEnabled = false
      }
      publicNetworkAccess = "Disabled"
    }
    kind = "AIServices"
    sku = {
      name = var.sku
    }
  })

  response_export_values = ["*"]
}

resource "azurerm_role_assignment" "managed_identity_storage_blob_data_contributor_role" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azapi_resource.ai_services_resource.identity[0].principal_id
}

module "private_endpoint_ai_services" {
  source                         = "../private_endpoint"
  name                           = azapi_resource.ai_services_resource.name
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azapi_resource.ai_services_resource.id
  location                       = var.location
  subnet_id                      = var.subnet_id
  subresource_names              = ["account"]
  is_manual_connection           = false
}
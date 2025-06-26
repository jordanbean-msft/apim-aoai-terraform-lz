# ------------------------------------------------------------------------------------------------------
# Deploy cognitive services
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "ai_foundry_account_name" {
  name          = "afa-${var.resource_token}"
  resource_type = "azurerm_cognitive_account"
  random_length = 0
  clean_input   = true
}

data "azapi_resource" "resource_group" {
  type = "Microsoft.Resources/resourceGroups@2021-04-01"
  name = var.resource_group_name
}

resource "azapi_resource" "ai_foundry_account" {
  type                      = "Microsoft.CognitiveServices/accounts@2025-04-01-preview"
  name                      = azurecaf_name.ai_foundry_account_name.result
  location                  = var.location
  parent_id                 = data.azapi_resource.resource_group.id
  schema_validation_enabled = false
  body = {
    kind = "AIServices"
    sku = {
      name = var.ai_foundry_sku
    }
    identity = {
      type = "UserAssigned"
      userAssignedIdentities = {
        "${var.user_assigned_identity_id}" = {}
      }
    }
    # identity = {
    #   type = "SystemAssigned"
    # }
    properties = {
      disableLocalAuth       = false
      allowProjectManagement = true
      customSubDomainName    = azurecaf_name.ai_foundry_account_name.result
      publicNetworkAccess    = "Disabled"
      networkAcls = {
        defaultAction = "Allow"
      }
      networkInjections = [
        {
          scenario                   = "agent"
          subnetArmId                = var.ai_foundry_agent_subnet_resource_id
          useMicrosoftManagedNetwork = false
        }
      ]
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "ai_foundry_account_diagnostic_setting" {
  name                       = "${azapi_resource.ai_foundry_account.name}-diagnostic-setting"
  target_resource_id         = azapi_resource.ai_foundry_account.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_log {
    category_group = "Audit"
  }

  metric {
    category = "AllMetrics"
  }
}

module "ai_foundry_account_private_endpoint" {
  source                         = "../private_endpoint"
  name                           = azapi_resource.ai_foundry_account.name
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azapi_resource.ai_foundry_account.id
  location                       = var.location
  subnet_id                      = var.subnet_id
  subresource_names              = ["account"]
  is_manual_connection           = false
}

resource "azurerm_role_assignment" "ai_foundry_account_openai_contributor_role_assignment" {
  scope                = azapi_resource.ai_foundry_account.id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = var.user_assigned_identity_object_id
}

# resource "azapi_resource" "conn_cosmosdb" {
#   type                      = "Microsoft.CognitiveServices/accounts/connections@2025-04-01-preview"
#   name                      = var.cosmos_db_account_name
#   parent_id                 = azapi_resource.ai_foundry_account.id
#   schema_validation_enabled = false

#   body = {
#     name = var.cosmos_db_account_name
#     properties = {
#       category = "CosmosDB"
#       target   = var.cosmos_db_account_endpoint
#       authType = "AAD"
#       metadata = {
#         ApiType    = "Azure"
#         ResourceId = var.cosmos_db_account_id
#         location   = var.location
#       }
#     }
#   }
# }

# ## Create the AI Foundry project connection to Azure Storage Account ##
# resource "azapi_resource" "conn_storage" {
#   type                      = "Microsoft.CognitiveServices/accounts/connections@2025-04-01-preview"
#   name                      = var.storage_account_name
#   parent_id                 = azapi_resource.ai_foundry_account.id
#   schema_validation_enabled = false
#   body = {
#     name = var.storage_account_name
#     properties = {
#       category = "AzureStorageAccount"
#       target   = "https://${var.storage_account_name}.blob.core.windows.net"
#       authType = "AAD"
#       metadata = {
#         ApiType    = "Azure"
#         ResourceId = var.storage_account_id
#         location   = var.location
#       }
#     }
#   }
# }

# ## Create the AI Foundry project connection to AI Search ##
# resource "azapi_resource" "conn_aisearch" {
#   type                      = "Microsoft.CognitiveServices/accounts/connections@2025-04-01-preview"
#   name                      = var.ai_search_name
#   parent_id                 = azapi_resource.ai_foundry_account.id
#   schema_validation_enabled = false

#   body = {
#     name = var.ai_search_name
#     properties = {
#       category = "CognitiveSearch"
#       target   = "https://${var.ai_search_name}.search.windows.net"
#       authType = "AAD"
#       metadata = {
#         ApiType    = "Azure"
#         ApiVersion = "2024-05-01-preview"
#         ResourceId = var.ai_search_id
#         location   = var.location
#       }
#     }
#   }
# }

## Create the AI Foundry project connection to AI Search ##
# resource "azapi_resource" "conn_apim" {
#   type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview"
#   name                      = var.api_management_name
#   parent_id                 = azapi_resource.ai_foundry_account.id
#   schema_validation_enabled = false

#   body = {
#     name = var.api_management_name
#     properties = {
#       category = "ApiManagement"
#       target   = "https://${var.api_management_gateway_url}.azure-api.net"
#       authType = "AAD"
#       metadata = {
#         ApiType    = "Azure"
#         ApiVersion = "2024-05-01-preview"
#         ResourceId = var.api_management_id
#         location   = var.location
#       }
#     }
#   }
# }

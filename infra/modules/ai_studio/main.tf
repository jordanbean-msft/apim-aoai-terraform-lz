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
      version = "1.15.0"
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
      description    = "This is my Azure AI hub"
      friendlyName   = "My Hub"
      storageAccount = var.storage_account_id
      keyVault       = var.key_vault_id

      applicationInsights = var.application_insights_id
      containerRegistry   = var.container_registry_id
    }
    kind = "hub"
  })
}

// Azure AI Project
resource "azapi_resource" "ai_project" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-04-01-preview"
  name      = "ai-project-${var.resource_token}"
  location  = var.location
  parent_id = var.resource_group_id

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      description   = "This is my Azure AI PROJECT"
      friendlyName  = "My Project"
      hubResourceId = azapi_resource.ai_hub.id
    }
    kind = "project"
  })
}

resource "azurerm_role_assignment" "managed_identity_storage_file_data_privileged_contributor_role" {
  scope                = var.storage_account_id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = azapi_resource.ai_project.identity[0].principal_id
}

// AzAPI AI Services Connection
resource "azapi_resource" "ai_services_connection" {
  type      = "Microsoft.MachineLearningServices/workspaces/connections@2024-04-01-preview"
  name      = "ais-connection-${var.resource_token}"
  parent_id = azapi_resource.ai_hub.id

  body = jsonencode({
    properties = {
      category      = "AIServices",
      target        = jsondecode(azapi_resource.ai_services_resource.output).properties.endpoint,
      authType      = "AAD",
      isSharedToAll = true,
      metadata = {
        ApiType    = "Azure",
        ResourceId = azapi_resource.ai_services_resource.id
      }
    }
  })
  response_export_values = ["*"]
}
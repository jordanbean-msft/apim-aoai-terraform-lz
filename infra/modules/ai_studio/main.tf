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
      source = "Azure/azapi"
      version = "1.15.0"
    }
  }
}
# ------------------------------------------------------------------------------------------------------
# Deploy AI Studio
# ------------------------------------------------------------------------------------------------------
# resource "azurecaf_name" "api_management_name" {
#   name          = var.resource_token
#   resource_type = "azurerm_api_management"
#   random_length = 0
#   clean_input   = true
# }

// AzAPI AIServices
resource "azapi_resource" "AIServicesResource" {
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

// Azure AI Hub
resource "azapi_resource" "hub" {
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
      containerRegistry  = var.container_registry_id
    }
    kind = "hub"
  })
}

// Azure AI Project
resource "azapi_resource" "project" {
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
      hubResourceId = azapi_resource.hub.id
    }
    kind = "project"
  })
}

// AzAPI AI Services Connection
resource "azapi_resource" "AIServicesConnection" {
  type      = "Microsoft.MachineLearningServices/workspaces/connections@2024-04-01-preview"
  name      = "ais-connection-${var.resource_token}"
  parent_id = azapi_resource.hub.id

  body = jsonencode({
    properties = {
      category      = "AIServices",
      target        = jsondecode(azapi_resource.AIServicesResource.output).properties.endpoint,
      authType      = "AAD",
      isSharedToAll = true,
      metadata = {
        ApiType    = "Azure",
        ResourceId = azapi_resource.AIServicesResource.id
      }
    }
  })
  response_export_values = ["*"]
}
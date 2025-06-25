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

# resource "azurerm_cognitive_account" "cognitive_account" {
#   for_each = {
#     for instance in flatten([
#       for pool in var.openai_model_deployments.pools : [
#         for openai_instance in pool.instances : {
#           name_suffix = openai_instance.name_suffix
#           kind        = openai_instance.kind
#           sku_name    = openai_instance.sku_name
#           location    = openai_instance.location
#         }
#       ]
#     ]) : instance.name_suffix => instance
#   }
#   name                          = azurecaf_name.cognitiveservices_name[each.key].result
#   location                      = each.value.location
#   resource_group_name           = var.resource_group_name
#   kind                          = each.value.kind
#   sku_name                      = each.value.sku_name
#   custom_subdomain_name         = azurecaf_name.cognitiveservices_name[each.key].result
#   public_network_access_enabled = false
#   network_acls {
#     default_action = "Deny"
#     ip_rules       = []
#   }
#   tags = var.tags
# }

resource "azurerm_cognitive_deployment" "cognitive_deployment" {
  for_each = {
    for instance in flatten([
      for pool in var.openai_model_deployments.pools : [
        for openai_instance in pool.instances : [
          for deployment in openai_instance.deployments : {
            name_suffix     = openai_instance.name_suffix
            model_format    = deployment.model.format
            model_name      = deployment.model.name
            model_version   = deployment.model.version
            sku_name        = deployment.sku.name
            sku_capacity    = deployment.sku.capacity
            rai_policy_name = deployment.rai_policy_name
          }
    ]]]) : "${instance.model_name}-${instance.name_suffix}" => instance
  }
  name = "${each.value.model_name}-${each.value.model_version}"
  #  cognitive_account_id = azurerm_cognitive_account.cognitive_account[each.value.name_suffix].id
  cognitive_account_id = azapi_resource.ai_foundry_account.id
  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }
  sku {
    name     = each.value.sku_name
    capacity = each.value.sku_capacity
  }
  rai_policy_name = each.value.rai_policy_name
}

module "private_endpoint" {
  source = "../private_endpoint"
  #name                           = azurerm_cognitive_account.cognitive_account[each.key].name
  name                = azapi_resource.ai_foundry_account.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
  resource_token      = var.resource_token
  #private_connection_resource_id = azurerm_cognitive_account.cognitive_account[each.key].id
  private_connection_resource_id = azapi_resource.ai_foundry_account.id
  location                       = var.location
  subnet_id                      = var.subnet_id
  subresource_names              = ["account"]
  is_manual_connection           = false
}

resource "azurerm_role_assignment" "cognitive_services_openai_contributor_role_assignment" {
  scope                = azapi_resource.ai_foundry_account.id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = var.user_assigned_identity_object_id
}

# resource "azurerm_monitor_diagnostic_setting" "openai_logging" {
#   for_each = {
#     for instance in flatten([
#       for pool in var.openai_model_deployments.pools : [
#         for openai_instance in pool.instances : {
#           name_suffix = openai_instance.name_suffix
#         }
#       ]
#     ]) : instance.name_suffix => instance
#   }
#   name                       = "${each.key}-openai-logging"
#   target_resource_id         = azurerm_cognitive_account.cognitive_account[each.key].id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   enabled_log {
#     category = "RequestResponse"
#   }

#   metric {
#     category = "AllMetrics"
#   }
# }

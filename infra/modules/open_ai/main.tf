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
# Deploy cognitive services
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "cognitiveservices_name" {
  for_each      = { for deployment in var.openai_model_deployments : deployment.name_suffix => deployment }
  name          = "openai-${var.resource_token}-${each.key}"
  resource_type = "azurerm_cognitive_account"
  random_length = 0
  clean_input   = true
}

resource "azurerm_cognitive_account" "cognitive_account" {
  for_each                      = { for deployment in var.openai_model_deployments : deployment.name_suffix => deployment }
  name                          = azurecaf_name.cognitiveservices_name[each.key].result
  location                      = each.value.location
  resource_group_name           = var.resource_group_name
  kind                          = each.value.kind
  sku_name                      = each.value.sku_name
  custom_subdomain_name         = azurecaf_name.cognitiveservices_name[each.key].result
  public_network_access_enabled = false
  network_acls {
    default_action = "Deny"
    ip_rules       = []
  }
  tags = var.tags
}

resource "azurerm_cognitive_deployment" "cognitive_deployment" {
  for_each = {
    for combination in flatten([
      for deployment in var.openai_model_deployments : [
        for model in deployment.deployments : {
          name_suffix   = deployment.name_suffix
          model_format  = model.model.format
          model_name    = model.model.name
          model_version = model.model.version
          sku_name      = model.sku.name
          sku_capacity  = model.sku.capacity
        }
      ]
    ]) : "${combination.model_name}-${combination.name_suffix}" => combination
  }
  name                 = "${each.value.model_name}-${each.value.model_version}"
  cognitive_account_id = azurerm_cognitive_account.cognitive_account[each.value.name_suffix].id
  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }

  sku {
    name     = each.value.sku_name
    capacity = each.value.sku_capacity
  }
}

module "private_endpoint" {
  for_each                       = { for deployment in var.openai_model_deployments : deployment.name_suffix => deployment }
  source                         = "../private_endpoint"
  name                           = azurerm_cognitive_account.cognitive_account[each.key].name
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azurerm_cognitive_account.cognitive_account[each.key].id
  location                       = each.value.location
  subnet_id                      = var.subnet_id
  subresource_names              = ["account"]
  is_manual_connection           = false
}

resource "azurerm_role_assignment" "cognitive_services_openai_contributor_role_assignment" {
  for_each             = { for deployment in var.openai_model_deployments : deployment.name_suffix => deployment }
  scope                = azurerm_cognitive_account.cognitive_account[each.key].id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = var.user_assigned_identity_object_id
}

resource "azurerm_monitor_diagnostic_setting" "openai_logging" {
  for_each                   = { for deployment in var.openai_model_deployments : deployment.name_suffix => deployment }
  name                       = "${each.key}-openai-logging"
  target_resource_id         = azurerm_cognitive_account.cognitive_account[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "RequestResponse"
  }

  metric {
    category = "AllMetrics"
  }
}
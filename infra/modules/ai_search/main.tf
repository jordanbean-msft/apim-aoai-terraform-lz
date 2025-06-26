# ------------------------------------------------------------------------------------------------------
# Deploy AI Search
# ------------------------------------------------------------------------------------------------------
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix  = [var.resource_token]
}

module "avm-res-search-searchservice" {
  source              = "Azure/avm-res-search-searchservice/azurerm"
  version             = "0.1.5"
  name                = module.naming.search_service.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  private_endpoints = {
    primary = {
      subnet_resource_id = var.private_endpoint_subnet_resource_id
    }
  }
  public_network_access_enabled = false
  diagnostic_settings = {
    default = {
      workspace_resource_id = var.log_analytics_workspace_resource_id
    }
  }
  sku = "standard"
  role_assignments = {
    search_index_data_contributor = {
      principal_id               = var.user_assigned_identity_principal_id
      principal_type             = "ServicePrincipal"
      role_definition_id_or_name = "Search Index Data Contributor"
    },
    search_service_contributor = {
      principal_id               = var.user_assigned_identity_principal_id
      principal_type             = "ServicePrincipal"
      role_definition_id_or_name = "Search Service Contributor"
    }
  }
  local_authentication_enabled = false
  hosting_mode                 = "default"
  partition_count              = 1
  replica_count                = 1
}

#Set the terraform required version, and Configure the Azure Provider.Use local storage

# Configure the Azure Provider
terraform {
  required_version = ">= 1.8.2, < 2.0.0"
  required_providers {
    azurerm = {
      version = "4.0.1"
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

  backend "azurerm" {
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {
}

# Make client_id, tenant_id, subscription_id and object_id variables
data "azurerm_client_config" "current" {}

terraform {
  required_version = "~> 1.9"
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 5.0.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.31"
    }

  }
}

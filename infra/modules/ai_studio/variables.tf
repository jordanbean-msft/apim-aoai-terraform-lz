variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "resource_group_id" {
  description = "The id of the resource group to deploy resources into"
  type        = string
}

variable "resource_token" {
  description = "A suffix string to centrally mitigate resource name collisions."
  type        = string
}

variable "tags" {
  description = "A list of tags used for deployed services."
  type        = map(string)
}

variable "sku" {
  type        = string
  description = "The sku name of the Azure Analysis Services server to create. Choose from: B1, B2, D1, S0, S1, S2, S3, S4, S8, S9. Some skus are region specific. See https://docs.microsoft.com/en-us/azure/analysis-services/analysis-services-overview#availability-by-region"
  default     = "S0"
}

variable "application_insights_id" {
  description = "The id of the application insights instance to use for logging"
  type        = string
}

variable "key_vault_id" {
  description = "The id of the key vault instance to use for secrets"
  type        = string
}

variable "storage_account_id" {
  description = "The id of the storage account instance to use for storage"
  type        = string
}

variable "container_registry_id" {
  description = "The id of the container registry instance to use for container images"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID to associate to the Azure Analysis Services server"
  type        = string
}
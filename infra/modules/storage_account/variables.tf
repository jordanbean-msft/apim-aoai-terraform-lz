variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy resources into"
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

variable "subnet_id" {
  description = "The subnet ID to associate to the storage account"
  type        = string
}

variable "account_tier" {
  description = "The Tier to use for this storage account"
  type        = string
}

variable "account_replication_type" {
  description = "The Replication type to use for this storage account"
  type        = string
}

variable "managed_identity_principal_id" {
  description = "The principal id of the managed identity"
  type        = string
}
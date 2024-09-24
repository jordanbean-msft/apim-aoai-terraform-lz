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

variable "managed_identity_principal_id" {
  description = "The User Assigned Managed Identity to assign to the container registry"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID to associate to the container registry"
  type        = string
}
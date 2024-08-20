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

variable "publisher_email" {
  description = "The API Management publisher email"
  type        = string
}

variable "publisher_name" {
  description = "The API Management publisher name"
  type        = string
}

variable "sku_name" {
  description = "The API Management SKU"
  type        = string
}

variable "user_assigned_identity_id" {
  description = "The User Assigned Managed Identity to assign to the API Management portal"
  type        = string
}

variable "api_management_subnet_id" {
  description = "The subnet ID to associate to the API Management portal"
  type        = string
}
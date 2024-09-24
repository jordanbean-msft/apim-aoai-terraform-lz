variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "tags" {
  description = "A list of tags used for deployed services."
  type        = map(string)
}

variable "resource_token" {
  description = "A suffix string to centrally mitigate resource name collisions."
  type        = string
}

variable "subnet_id" {
  description = "The resource id of the subnet to deploy the private endpoint into"
  type        = string
}

variable "user_assigned_identity_name" {
  description = "The name of the user assigned identity"
  type        = string
}

variable "user_assigned_identity_object_id" {
  description = "The object id of the user assigned identity"
  type        = string
}

variable "capacity" {
  description = "The size of the Redis cache to deploy"
  type        = number
}

variable "sku_name" {
  description = "The SKU of the Redis cache to deploy"
  type        = string
}

variable "zones" {
  description = "The availability zones to deploy the Redis cache into"
  type        = list(string)
}
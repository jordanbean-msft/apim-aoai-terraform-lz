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

variable "principal_id" {
  description = "The Id of the service principal to add to deployed keyvault access policies"
  sensitive   = true
  type        = string
}

variable "access_policy_object_ids" {
  description = "A list of object ids to be be added to the keyvault access policies"
  type        = list(string)
  sensitive   = true
  default     = []
}

variable "secrets" {
  description = "A list of secrets to be added to the keyvault"
  type = list(object({
    name  = string
    value = string
  }))
  sensitive = true
}

variable "subnet_id" {
  description = "The resource id of the subnet to deploy the private endpoint into"
  type        = string
}

variable "private_dns_zone_group_ids" {
  description = "A list of private dns zone ids to be added to the private dns zone group"
  type        = list(string)
  sensitive   = true
}

variable "public_network_access_enabled" {
  description = "Whether or not public network access is enabled"
  type        = bool
}
variable "rg" {
  type        = string
  description = "resource group name"
}

variable "subnet_name" {
  type        = string
  description = "subnet name"
}


variable "vnet_name" {
  type        = string
  description = "subnet name"
}

variable "location" {
  type        = string
  description = "location for vnet"
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
}

variable "client_id" {
  description = "Azure Client ID for OIDC authentication"
  type        = string
  default     = ""
}

variable "tenant_id" {
  description = "Azure Tenant ID for OIDC authentication"
  type        = string
  default     = ""
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = ""
}

variable "oidc_token_file_path" {
  description = "Path to OIDC token file"
  type        = string
  default     = ""
}

variable "azure_object_id" {
  description = "Azure Object ID for OIDC authentication"
  type        = string
}

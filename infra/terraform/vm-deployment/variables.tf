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

variable "azure_object_id" {
  description = "Azure Object ID for OIDC authentication"
  type        = string
}

variable "tf_storage_rg" {
  description = "Resrouce group name containing the storage account for Terraform State"
  type        = string
}

variable "tf_storage_account_name" {
  description = "Resrouce group name containing the storage account for Terraform State"
  type        = string
}

variable "tf_container_name" {
  description = "Resrouce group name containing the storage account for Terraform State"
  type        = string
}

variable "nic_name" {
  description = "Name of the Network Interface Card"
  type        = string
}

variable "location" {
  type        = string
  description = "Location where the resource will be hosted"
}

variable "rg" {
  type        = string
  description = "Resource group"
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
}

variable "prefix" {
  description = "Prefix of the name for the resource"
  type        = string
}

variable "user_assigned_identity_name" {
  description = "The name of the user-assigned managed identity that's used by the VM"
  type        = string
}

variable "acr_name" {
  description = "Azure Container Registry name"
  type        = string
}

variable "admin_enabled" {
  description = "Enable admin user for the Azure Container Registry"
  type        = bool
  default     = false
}

variable "sku" {
  description = "The SKU of the Azure Container Registry"
  type        = string
  default     = "Standard"
}

variable "acr_pull_role_name" {
  type        = string
  description = "The name of the AcrPull role given to the user-assigned identity"
  default     = "AcrPull"
}

variable "network_contributor_role_name" {
  type        = string
  description = "The name of the Network Contributor role given to the user-assigned identity"
  default     = "Network Contributor"
}

variable "vm_ssh_public_key" {
  type        = string
  description = "File path of the SSH Public Key"
}

variable "uami_ids" {
  type        = list(string)
  description = "List of UAMI Ids to be assigned to the VM"
}

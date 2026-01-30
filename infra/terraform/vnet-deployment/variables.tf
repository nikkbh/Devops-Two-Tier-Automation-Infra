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

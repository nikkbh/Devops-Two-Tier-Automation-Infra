terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  backend "azurerm" {
    key      = "terraform.tfstate"
    use_oidc = true
  }
}

provider "azurerm" {
  features {}
  use_oidc             = true
  client_id            = var.client_id
  tenant_id            = var.tenant_id
  subscription_id      = var.subscription_id
  oidc_token_file_path = var.oidc_token_file_path
}

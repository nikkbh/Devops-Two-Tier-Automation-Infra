data "terraform_remote_state" "networking" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.tf_storage_rg
    storage_account_name = var.tf_storage_account_name
    container_name       = var.tf_container_name
    key                  = "terraform.tfstate"
  }
}

# uami
module "user_assigned_identity" {
  source   = "../modules/user-assigned-identity"
  name     = var.user_assigned_identity_name
  location = var.location
  rg_name  = module.resource-group.name
  tags     = var.tags
}

# rg
module "rg" {
  source   = "../modules/resource-group"
  name     = var.rg
  location = var.location
  tags     = var.tags
}

# nic (remove from vnet deployment)
module "nic" {
  source    = "../modules/network-interface-card"
  name      = var.nic_name
  location  = var.location
  rg        = module.rg
  subnet_id = data.terraform_remote_state.networking.outputs.subnet_id
}

# ssh-key
module "ssh-key" {
  source                  = "../modules/ssh-key"
  resource_group_id       = module.rg.id
  resource_group_location = var.location
  azure_object_id         = data.azurerm_client_config.current.object_id
}

# vm
module "vm" {
  source              = "../modules/linux-virtual-machine"
  prefix              = var.prefix
  location            = var.location
  nic_id              = module.nic.nic_id
  resource_group_name = module.rg
  ssh_key             = module.ssh-key.key_data
}

# acr
module "acr" {
  source                    = "../modules/azure-container-registry"
  name                      = var.acr_name
  location                  = var.location
  rg_name                   = module.rg.name
  user_assigned_identity_id = module.user_assigned_identity
  tags                      = var.tags
  sku                       = var.acr_name
  admin_enabled             = var.admin_enabled
}

module "acr_pull_role" {
  source       = "../modules/role-assignment"
  principal_id = module.user_assigned_identity.user_assinged_identity_principal_id
  role_name    = var.acr_pull_role_name
  scope_id     = module.acr.acr_id
}

module "network_contributor_role" {
  source       = "../modules/role-assignment"
  principal_id = module.user_assigned_identity.user_assinged_identity_principal_id
  role_name    = var.network_contributor_role_name
  scope_id     = module.rg.id
}


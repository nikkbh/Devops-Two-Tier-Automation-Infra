module "resource-group" {
  source   = "../modules/resource-group"
  name     = var.rg
  location = var.location
  tags     = var.tags
}
module "subnet" {
  source      = "../modules/subnet"
  rg          = module.resource-group.name
  vnet_name   = var.vnet_name
  subnet_name = var.subnet_name
}

module "virtual-network" {
  source    = "../modules/virtual-network"
  rg        = module.resource-group.name
  location  = var.location
  vnet_name = var.vnet_name
}


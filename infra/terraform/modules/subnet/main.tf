resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.rg
  address_prefixes     = ["10.0.1.0/24"]
}

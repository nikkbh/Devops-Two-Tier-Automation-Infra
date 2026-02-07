rg       = "rg-vm"
location = "centralindia"
tags = {
  environment = "prod"
  owner       = "nikhil"
  application = "two-tier-app"
  location    = "centralindia"
}

tf_storage_rg           = "terraform-rg"
tf_storage_account_name = "tftwotierappaccount"
tf_container_name       = "tftwotierappcontaienr"

nic_name                    = "twotierapp-nic"
prefix                      = "towtierapp"
acr_name                    = "twotierapp-acr"
user_assigned_identity_name = "UAMI_VM"

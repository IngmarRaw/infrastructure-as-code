terraform {
  backend "azurerm" {
    resource_group_name  = "S1073133"
    storage_account_name = "ingmarrawstorage"
    container_name       = "tfstate"
    key                  = "les-05-opdracht-1.tfstate"
    use_azuread_auth     = true
  }
}
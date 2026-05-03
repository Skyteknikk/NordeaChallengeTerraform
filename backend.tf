terraform {
  backend "azurerm" {
    resource_group_name  = "Nordea-Infra-tfstate-RG"
    storage_account_name = "nordeasttfstate51562"
    container_name       = "nordeatfstate"
    key                  = "nordea-challenge/dev.tfstate"
  }
}
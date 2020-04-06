terraform {
  required_version = ">= 0.12"
}

# Configure the Azure Provider
provider "azurerm" {
  version = "=2.2.0"
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform"
    storage_account_name = "tebrielterraformstate"
    container_name       = "hasthecurveflattened"
    key                  = "terraform.tfstate"
  }
}

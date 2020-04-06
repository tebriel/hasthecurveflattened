data "azurerm_resource_group" "hasthecurveflattened-com" {
  name = "has-the-curve-flattened"
}

data "azurerm_dns_zone" "site" {
  name                = "hasthecurveflattened.com"
  resource_group_name = data.azurerm_resource_group.hasthecurveflattened-com.name
}

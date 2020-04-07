resource "azurerm_storage_account" "site" {
  name                      = "hasthecurveflattened"
  resource_group_name       = data.azurerm_resource_group.hasthecurveflattened-com.name
  location                  = data.azurerm_resource_group.hasthecurveflattened-com.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  enable_https_traffic_only = false
  static_website {
    index_document = "index.html"
  }
  tags = {}

}

resource "azurerm_storage_container" "web" {
  name                  = "$web"
  storage_account_name  = azurerm_storage_account.site.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "index" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.site.name
  storage_container_name = azurerm_storage_container.web.name
  type                   = "Block"
  source_content         = file("${path.module}/../src/index.html")
  content_type           = "text/html"

}

resource "azurerm_dns_cname_record" "www" {
  name                = "www"
  zone_name           = data.azurerm_dns_zone.site.name
  resource_group_name = data.azurerm_resource_group.hasthecurveflattened-com.name
  ttl                 = 60
  record              = azurerm_cdn_endpoint.flattened.host_name
}

resource "azurerm_dns_a_record" "root" {
  name                = "@"
  zone_name           = data.azurerm_dns_zone.site.name
  resource_group_name = data.azurerm_resource_group.hasthecurveflattened-com.name
  ttl                 = 60
  target_resource_id  = azurerm_cdn_endpoint.flattened.id
}

resource "azurerm_cdn_profile" "site" {
  name                = "hasthecurveflattenedCDNProfile"
  location            = data.azurerm_resource_group.hasthecurveflattened-com.location
  resource_group_name = data.azurerm_resource_group.hasthecurveflattened-com.name
  sku                 = "Standard_Verizon"
}

resource "azurerm_cdn_endpoint" "flattened" {
  name                   = "flattened"
  profile_name           = azurerm_cdn_profile.site.name
  location               = data.azurerm_resource_group.hasthecurveflattened-com.location
  resource_group_name    = data.azurerm_resource_group.hasthecurveflattened-com.name
  is_compression_enabled = true
  origin_host_header     = azurerm_storage_account.site.primary_web_host

  origin {
    name      = replace(azurerm_storage_account.site.primary_blob_host, ".", "-")
    host_name = azurerm_storage_account.site.primary_web_host
  }

  content_types_to_compress = [
    "text/html"
  ]
}

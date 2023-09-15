data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.cluster_region
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.vnet_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  virtual_network_name = azurerm_virtual_network.this.name
  resource_group_name  = azurerm_resource_group.this.name
  address_prefixes     = ["10.1.0.0/22"]
}

resource "azurerm_virtual_network" "app_vnet" {
  name                = "${var.second_vnet_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "app_vnet_internal" {
  name                 = "internal"
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  resource_group_name  = azurerm_resource_group.this.name
  address_prefixes     = ["10.2.0.0/22"]
}


resource "azurerm_virtual_network_peering" "vnet1_to_vnet2" {
  name                         = "${var.vnet_name}-to-${var.second_vnet_name}"
  resource_group_name          =  azurerm_resource_group.this.name
  virtual_network_name         = azurerm_virtual_network.this.name
  remote_virtual_network_id    = azurerm_virtual_network.app_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "vnet2_to_vnet1" {
  name                         = "${var.second_vnet_name}-to-${var.vnet_name}"
  resource_group_name          = azurerm_resource_group.this.name
  virtual_network_name         = azurerm_virtual_network.app_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.this.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

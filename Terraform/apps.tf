locals {
  backend_address_pool_name      = "${azurerm_virtual_network.app_vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.app_vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.app_vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.app_vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.app_vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.app_vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.app_vnet.name}-rdrcfg"
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.resource_group_name}-plan"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "app_service" {
  name                = "${var.resource_group_name}-webapp"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  
}

resource "azurerm_public_ip" "my-gw-pip" {
  name                = "${var.resource_group_name}-gw-pip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "${var.resource_group_name}-app-gateway"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
   depends_on          = [azurerm_public_ip.my-gw-pip]

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "${var.resource_group_name}-ip-configuration"
    subnet_id = azurerm_subnet.app_snet_internal.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 443
  }

  frontend_ip_configuration {
    name      = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.my-gw-pip.id
  }

  http_listener {
    name                  = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Https"
    ssl_certificate_name           = "kubily-ssl-certificate"
  }

  ssl_certificate {
    name     = "kubily-ssl-certificate"
    data     = filebase64("C://Users/dhawa/Downloads/kubily.pfx")
    password = ""
  }

  request_routing_rule {
    name                       =  local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority = 1
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    fqdns = ["${azurerm_app_service.app_service.name}.azurewebsites.net"]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    host_name = "emptest1.kubily.com"
    probe_name = "custom-probe"
  }
  
  probe {
    name                      = "custom-probe"
    protocol                  = "Http"  
    host                      = "${azurerm_app_service.app_service.name}.azurewebsites.net"  # Replace with your backend hostname
    path                      = "/"  # Replace with your health check path
    interval                  = 30
    timeout                   = 30
    unhealthy_threshold       = 3
    # backend_http_settings_name = local.http_setting_name
    pick_host_name_from_backend_http_settings = false
  }
}


# resource "azurerm_private_endpoint" "app-pvt-endpoint" {
#   name                = "${var.resource_group_name}-private-endpoint"
#   location            = azurerm_resource_group.this.location
#   resource_group_name = azurerm_resource_group.this.name
#   subnet_id = azurerm_subnet.app_snet_internalv2.id
  
#   private_service_connection {
#     name                           = "${var.resource_group_name}-private-connection"
#     private_connection_resource_id = azurerm_app_service.app_service.id
#     subresource_names              = ["sites"]
#     is_manual_connection           = false
#   }
# }
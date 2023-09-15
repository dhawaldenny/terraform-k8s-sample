
resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  dns_prefix          = var.cluster_name
#  node_resource_group = "${var.cluster_name}-ng"

  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = var.node_size
    vnet_subnet_id = azurerm_subnet.internal.id
  }

network_profile {
    network_plugin = "azure"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Test"
  }

   windows_profile {
    admin_username = "Microsoft"
    admin_password = "M1cr0s0ft@2023"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "win" {
  name  = "win"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  node_count     = var.node_count
  vm_size        = var.node_size
  os_type               = "Windows"
}


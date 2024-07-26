resource "azurerm_resource_group" "testapp" {
  name     = "${var.prefix}-k8s-resources"
  location = var.location
}

resource "azurerm_virtual_network" "testapp" {
  name                = "${var.prefix}-network"
  location            = azurerm_resource_group.testapp.location
  resource_group_name = azurerm_resource_group.testapp.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  virtual_network_name = azurerm_virtual_network.testapp.name
  resource_group_name  = azurerm_resource_group.testapp.name
  address_prefixes     = ["10.1.0.0/22"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "gateway"
  virtual_network_name = azurerm_virtual_network.testapp.name
  resource_group_name  = azurerm_resource_group.testapp.name
  address_prefixes     = ["10.1.4.0/22"]
}



resource "azurerm_kubernetes_cluster" "testapp" {
  name                = "${var.prefix}-k8s"
  location            = azurerm_resource_group.testapp.location
  resource_group_name = azurerm_resource_group.testapp.name
  dns_prefix          = "${var.prefix}-k8s"

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.internal.id
  }

  ingress_application_gateway {
    subnet_id = azurerm_subnet.gateway.id
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "aks_agic_integration" {
  scope = azurerm_virtual_network.testapp.id
  role_definition_name = "Network Contributor"
  principal_id = azurerm_kubernetes_cluster.testapp.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id

  depends_on = [
    azurerm_virtual_network.testapp,
    azurerm_kubernetes_cluster.testapp
    ]
}



resource "azurerm_kubernetes_cluster" "my_aks" {
  name                = "my-aks"
  location            = data.azurerm_resource_group.my_resource.location
  resource_group_name = data.azurerm_resource_group.my_resource.name
  dns_prefix          = "my-aks-dns"
  kubernetes_version  = "1.29.4"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
    vnet_subnet_id  = azurerm_subnet.private_subnet.id
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "Demo"
  }
}
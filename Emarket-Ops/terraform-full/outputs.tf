# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.my_aks.name
}

output "public_subnet_id" {
  value = azurerm_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private_subnet.id
}

output "bastion_subnet_id" {
  value = azurerm_subnet.bastion_subnet.id
}

output "nat_gateway_public_ip" {
  value = azurerm_public_ip.nat_public_ip.ip_address
}

output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_public_ip.ip_address
}
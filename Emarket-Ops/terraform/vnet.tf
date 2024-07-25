provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "my_resource" {
  name = "my-resource"
}

resource "azurerm_network_security_group" "public_nsg" {
  name                = "public-nsg"
  location            = data.azurerm_resource_group.my_resource.location
  resource_group_name = data.azurerm_resource_group.my_resource.name

  security_rule {
    name                       = "allow-ssh-01-inbound"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "178.128.59.75"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ssh-02-inbound"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "159.223.82.169"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "private_nsg" {
  name                = "private-nsg"
  location            = data.azurerm_resource_group.my_resource.location
  resource_group_name = data.azurerm_resource_group.my_resource.name

  security_rule {
    name                       = "allow-http-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https-inbound"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "my_vnet" {
  name                = "my-vnet"
  location            = data.azurerm_resource_group.my_resource.location
  resource_group_name = data.azurerm_resource_group.my_resource.name
  address_space       = ["192.168.0.0/20"]

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = data.azurerm_resource_group.my_resource.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["192.168.4.0/22"]
}

resource "azurerm_subnet" "private_subnet" {
  name                 = "private-subnet"
  resource_group_name  = data.azurerm_resource_group.my_resource.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["192.168.8.0/22"]
}

resource "azurerm_route_table" "public_rtb" {
  name                = "public-rtb"
  location            = data.azurerm_resource_group.my_resource.location
  resource_group_name = data.azurerm_resource_group.my_resource.name

  route {
    name            = "default-route"
    address_prefix  = "0.0.0.0/0"
    next_hop_type   = "Internet"
  }

  route {
    name            = "internal-route"
    address_prefix  = "192.168.0.0/20"
    next_hop_type   = "VnetLocal"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_route_table" "private_rtb" {
  name                = "private-rtb"
  location            = data.azurerm_resource_group.my_resource.location
  resource_group_name = data.azurerm_resource_group.my_resource.name

  route {
    name            = "default-route"
    address_prefix  = "0.0.0.0/0"
    next_hop_type   = "Internet"
  }

  route {
    name            = "internal-route"
    address_prefix  = "192.168.0.0/20"
    next_hop_type   = "VnetLocal"
  }


  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_network_security_group_association" "public_nsg_association" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "private_nsg_association" {
  subnet_id                 = azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.private_nsg.id
}

resource "azurerm_subnet_route_table_association" "public_subnet_rtb_association" {
  subnet_id      = azurerm_subnet.public_subnet.id
  route_table_id = azurerm_route_table.public_rtb.id
}

resource "azurerm_subnet_route_table_association" "private_subnet_rtb_association" {
  subnet_id      = azurerm_subnet.private_subnet.id
  route_table_id = azurerm_route_table.private_rtb.id
}


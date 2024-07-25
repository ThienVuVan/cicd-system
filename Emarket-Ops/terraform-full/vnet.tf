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

  security_rule {
    name                       = "allow-ssh-inbound"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "178.128.59.75"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "private_nsg" {
  name                = "private-nsg"
  location            = data.azurerm_resource_group.my_resource.location
  resource_group_name = data.azurerm_resource_group.my_resource.name
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

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = data.azurerm_resource_group.my_resource.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["192.168.1.0/26"]
}

resource "azurerm_public_ip" "nat_public_ip" {
  name                = "nat-public-ip"
  location            = data.azurerm_resource_group.my_resource.location
  resource_group_name = data.azurerm_resource_group.my_resource.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "bastion-public-ip"
  location            = data.azurerm_resource_group.my_resource.location
  resource_group_name = data.azurerm_resource_group.my_resource.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "my_nat_gateway" {
  name                = "my-nat-gateway"
  location            = data.azurerm_resource_group.my_resource.location
  resource_group_name = data.azurerm_resource_group.my_resource.name
  sku_name            = "Standard"
}

resource "azurerm_bastion_host" "my_bastion" {
  name                = "my-bastion"
  location            = data.azurerm_resource_group.my_resource.location
  resource_group_name = data.azurerm_resource_group.my_resource.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
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

resource "azurerm_nat_gateway_public_ip_association" "nat_public_ip_association" {
  nat_gateway_id       = azurerm_nat_gateway.my_nat_gateway.id
  public_ip_address_id = azurerm_public_ip.nat_public_ip.id
}

resource "azurerm_subnet_nat_gateway_association" "private_subnet_nat_association" {
  subnet_id      = azurerm_subnet.private_subnet.id
  nat_gateway_id = azurerm_nat_gateway.my_nat_gateway.id
}


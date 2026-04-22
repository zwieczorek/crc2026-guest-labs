resource "azurerm_virtual_network" "default" {
  name                = "${var.prefix}-vnet-XXX"
  location            = data.azurerm_resource_group.default.location
  resource_group_name = data.azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/16"]

  tags = var.tags
}


resource "azurerm_subnet" "one" {
  name                 = "${var.prefix}-one"
  resource_group_name  = data.azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "two" {
  name                 = "${var.prefix}-two"
  resource_group_name  = data.azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "default" {
  name                = "${var.prefix}-xx-nsg"
  location            = data.azurerm_resource_group.default.location
  resource_group_name = data.azurerm_resource_group.default.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "one" {
  subnet_id                 = azurerm_subnet.one.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_public_ip" "default" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = data.azurerm_resource_group.default.name
  location            = data.azurerm_resource_group.default.location
  allocation_method   = "Static"

  tags = var.tags
}

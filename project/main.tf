resource "azurerm_virtual_network" "default" {
  name                = "vnet-xxx"
  location            = data.azurerm_resource_group.default.location
  resource_group_name = data.azurerm_resource_group.default.name
  address_space       = ["172.24.0.0/16"]

  tags = local.tags
}


resource "azurerm_subnet" "apps" {
  name                 = "apps"
  resource_group_name  = data.azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["172.24.0.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "data"
  resource_group_name  = data.azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["172.24.1.0/24"]
}

resource "azurerm_network_security_group" "default" {
  name                = "xx-nsg"
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

  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "apps" {
  subnet_id                 = azurerm_subnet.apps.id
  network_security_group_id = azurerm_network_security_group.default.id
}


resource "azurerm_public_ip" "default" {
  name                = "public-ip"
  resource_group_name = data.azurerm_resource_group.default.name
  location            = data.azurerm_resource_group.default.location
  allocation_method   = "Static"

  tags = local.tags
}


resource "azurerm_network_interface" "default" {
  name                = "xx-nic"
  location            = data.azurerm_resource_group.default.location
  resource_group_name = data.azurerm_resource_group.default.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.apps.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.default.id
  }
}

resource "azurerm_linux_virtual_machine" "default" {
  name                = "xx-vm"
  resource_group_name = data.azurerm_resource_group.default.name
  location            = data.azurerm_resource_group.default.location
  size                = "Standard_B1ls"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.default.id,
  ]
  ## Dla etapu 5+ nie ustawiaj admin_password oraz disable_password_authentication
  admin_password                  = var.password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  ## Etap 5+
  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.default.public_key_openssh
  }

}

## Etap 5+
# RSA key of size 4096 bits
resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

## Zapisz do pliku klucze ssh, provate i public
resource "local_file" "public" {
  content  = tls_private_key.default.public_key_openssh
  filename = "${path.module}/pub_key.pub"
}

resource "local_file" "private" {
  content  = tls_private_key.default.private_key_pem
  filename = "${path.module}/private_key"

  file_permission = "0600"
}


# 🎓 Terraform Azure Lab – Kompletny przewodnik

## 🎯 Cel

Celem tego projektu jest nauczenie się podstaw **Terraform na platformie Azure** poprzez stworzenie **działającej infrastruktury** - **maszyny wirtualnej z Linuxem**, do której można zalogować się przez **SSH**.

### Etap 1: Sieć
Stwórz:
- Virtual Network (CIDR: 172.24.0.0/16)
- Subnet `apps` (172.24.0.0/24)
- Subnet `data` (172.24.1.0/24)

Użyj:
- `azurerm_virtual_network`
- `azurerm_subnet`

Dodaj tag:
- `owner`

pozostałych paramaterów opcjonalnych nie definiuj.


### Etap 2:  NSG
Stwórz NSG z następującą konfuguracją:

```hcl
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
```
przypisz te nsg do subnetu apps. Skorzystaj z resourców azurerm_network_security_group i azurerm_subnet_network_security_group_association
### Etap 3 Publiczne IP + NIC
Stwórz:
- publiczny adres ip ze statyczną metodą alokacji
- NIC w subnecie `apps` z dynamiczna alokacja IP dla adresów prywatnych, ustaw odpowiednio public_ip_address_id

Użyj resourców azurerm_public_ip oraz azurerm_network_interface


### Etap 4: Virtual Machine

- Linux (Ubuntu 22.04)
- Hasło z `variable`
- `disable_password_authentication = false`
- Podłącz NIC

```hcl
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
```


---

### Etap 5: SSH

Po `terraform apply` połącz się:

```bash
ssh <user>@<public-ip>
```

✅ Jeśli się zalogujesz – zadanie wykonane poprawnie!

### Etap 6
Po zakończonej pracy usuń resourcy poleceniem
```bash
terraform destroy
```



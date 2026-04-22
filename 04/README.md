# 🧪 Terraform Lab — Azure Infrastructure

> Ćwiczenie praktyczne: moduły, maszyna wirtualna, klucze SSH, App Service.


## 📁 Etap 0: Struktura projektu

Zanim napiszesz pierwszą linię kodu, utwórz poniższą strukturę katalogów:

```
04/
│
├── main.tf                  ← root module: VM + App Service
├── variables.tf             ← zmienne root module
├── outputs.tf               ← outputy root module
├── providers.tf              ← providerzy
│
└── modules/
    ├── network/                ← Moduł 1: sieć, subnet etc.
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── versions.tf
    │   └── outputs.tf
    │
    └── web/    ← Moduł 2: App Service Plan, storage acocunt etc.
        ├── main.tf
        ├── variables.tf
        ├── versions.tf
        └── outputs.tf
```
## 🌐 Etap 1: Moduł network

Moduł `modules/network/` ma tworzyć kompletną infrastrukturę sieciową:
- Virtual Network (`10.0.0.0/16`)
- Dwa subnety: `one` (`10.0.0.0/24`) i `two` (`10.0.1.0/24`)
- Public IP
- Network Security Group z regułami HTTP/HTTPS/SSH
- Powiązanie NSG z subnetem `one`

Użyj resourców:

- azurerm_virtual_network
- azurerm_subnet
- azurerm_public_ip
- azurerm_network_security_group
- azurerm_subnet_network_security_group_association

NSG powinno mieć następującą konfigurację:

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
Twój moduł powinien outputować location. Zmienne wejściowe to nazwa resource grupy. W razie potrzeby, dodaj variable i outputs wedle uznania.

Tworząc nazwy resourców używaj zmainnej variable 'prefix' (zdefiniuj ja w kodzie).

Używając modułu network, zdeploy'uj konfigurację w root module.

---

## 💻 Etap 2: Root module — Maszyna Wirtualna z kluczem SSH

W root module tworzymy:
1. Network Interface
2. Maszynę wirtualną Ubuntu 22.04 opartą na haśle

Użyj: azurerm_linux_virtual_machine oraz azurerm_network_interface.

### 🔐 Logowanie na VM przez SSH
Po `terraform apply` połącz się:

```bash
ssh <user>@<public-ip>
```
---

## ☁️ Etap 3: Moduł App Service Plan

Moduł `modules/web/` ma tworzyć tworzy tylko app service plan oraz storage account. Użyj azurerm_linux_function_app
(sku  B1, os_type Linux) oraz azurerm_storage_account (account tier Standard, replication_tyep LRS). Niech Twój moduł przyjmuje jako zmianną location resource grupy, jej nazwę i prefix do generowania nazw zasobów. Dodatkowe variable i outputy zdefiniuj wedle uznania.

Wowołaj swój moduł w rool module. Location powinna byc wzięta z modułu network.

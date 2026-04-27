# Zadanie: Moduł Key Vault z sekretem + moduł VM z hasłem z Key Vault

## Cel

Napisz konfigurację Terraform złożoną z dwóch modułów:

- **Moduł `keyvault`** — tworzy Azure Key Vault, Access Policy i losowo generowany sekret z hasłem
- **Moduł `vm`** — tworzy sieć, maszynę wirtualną Ubuntu i loguje się przez hasło **pobrane z Key Vault**

Kluczowy element zadania: maszyna wirtualna nie dostaje hasła "z powietrza" — wartość sekretu z Key Vault staje się hasłem admina VM.

Konfiguracja korzysta z **remote backend** skonfigurowanego w lab 05 oraz z providerów `azurerm` i `random`.

Ćwiczenie składa się z 4 etapów.

---

## Struktura plików

```
07/
├── main.tf                  ← wywołanie obu modułów + przekazanie hasła
├── variables.tf
├── outputs.tf
├── providers.tf             ← remote backend, azurerm, random
├── data.tf                  ← resource group + dane klienta (tenant/object ID)
├── locals.tf                ← tagi
│
└── modules/
    ├── keyvault/            ← Moduł 1: Key Vault, Access Policy, sekret
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │   └── versions.tf
    └── vm/                  ← Moduł 2: VNet, subnet, NSG, NIC, VM
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
        └── versions.tf
```

---

## Etap 1 — Remote backend i providerzy

Skonfiguruj `providers.tf` z backendem z lab 05 i dwoma providerami: `azurerm` i `random`.

```hcl
terraform {
  required_version = "~> 1.10"

  backend "azurerm" {
    resource_group_name  = "<resource_group_z_lab05>"
    storage_account_name = "<nazwa_storage_account_z_lab05>"
    container_name       = "<nazwa_kontenera_z_lab05>"
    key                  = "lab07.terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.70.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  resource_provider_registrations = "none"
  subscription_id                 = "ID_HERE"
}
```

Zdefiniuj w `data.tf`:

```hcl
data "azurerm_resource_group" "main" {
  name = "RG_NAME_HERE"
}

data "azurerm_client_config" "current" {} # do pobrania informacji o tenacie i object_id
```

Zainicjuj projekt:

```bash
terraform init
```

---

## Etap 2 — Moduł `keyvault`
Bazując na zadaniu 06 stwórz keyvault wraz z azurerm_key_vault_secret oraz access policy. Uzyj providera random.

---

## Etap 3 — Moduł `vm`

### `modules/vm/variables.tf`

Zdefiniuj zmienne: `prefix`, `resource_group_name`, `location`, `admin_password` (typ `string`, `sensitive = true`), `tags`.

### `modules/vm/main.tf`

Utwórz kompletną infrastrukturę do uruchomienia VM:

**Sieć:**
- `azurerm_virtual_network` — CIDR `10.0.0.0/16`
- `azurerm_subnet` — CIDR `10.0.0.0/24`
- `azurerm_public_ip` — alokacja `Static`
- `azurerm_network_security_group` — reguła zezwalająca na SSH (port 22, inbound, TCP)
- `azurerm_subnet_network_security_group_association` — powiąż NSG z subnetem

**Compute:**
- `azurerm_network_interface` — dynamiczne IP prywatne, przypisz Public IP
- `azurerm_linux_virtual_machine`:
  - Rozmiar: `Standard_B1ls`
  - `admin_username`: `adminuser`
  - `admin_password`: **z zmiennej** `var.admin_password`
  - `disable_password_authentication`: `false`
  - OS disk: `ReadWrite` / `Standard_LRS`
  - Obraz: Ubuntu Server 22.04 LTS (`Canonical` / `0001-com-ubuntu-server-jammy` / `22_04-lts`)


W razie problemów, zerknij do ćwiczenia 04.
### `modules/vm/outputs.tf`

Zwróć z modułu:
- `public_ip_address` — publiczny adres IP maszyny wirtualnej

---

## Etap 4 — Root module: połącz moduły

### `main.tf`

Wywołaj oba moduły. Zwróć uwagę na przekazanie hasła:

```hcl
module "keyvault" {
  source = "./modules/keyvault"

  prefix              = var.prefix
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  tags                = local.tags
}

module "vm" {
  source = "./modules/vm"

  prefix              = var.prefix
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  admin_password      = module.keyvault.secret_value   # <-- hasło z Key Vault
  tags                = local.tags
}
```

### `outputs.tf`

Dodaj outputy:
- `vm_public_ip` — publiczne IP VM (z `module.vm.public_ip_address`)
- `key_vault_name` — nazwa KV (z `module.keyvault.key_vault_name`)

### Wdróż

```bash
terraform apply
```

Terraform najpierw stworzy Key Vault i sekret, a dopiero potem VM — dzięki niejawnemu powiązaniu przez zmienną `admin_password`.

---

## Weryfikacja

### Pobierz hasło z Key Vault

```bash
az keyvault secret show \
  --vault-name $(terraform output -raw key_vault_name) \
  --name vm-admin-password \
  --query value \
  --output tsv
```

### Zaloguj się na VM przez SSH

```bash
ssh adminuser@public_ip
```

Podaj hasło pobrane z Key Vault (az cli lub Azure portal) — jeśli logowanie się powiedzie, zadanie jest poprawnie wykonane.

---

## Wskazówki

- `sensitive = true` na outputcie modułu sprawia, że Terraform nie wypisze wartości w terminalu — to oczekiwane zachowanie.
- Przekazanie `module.keyvault.secret_value` jako `admin_password` tworzy **niejawną zależność** — Terraform wie, że musi najpierw wdrożyć Key Vault.
- Jeśli `terraform apply` zgłosi błąd `KeyVaultNotFound` przy tworzeniu sekretu, upewnij się, że `depends_on` jest ustawiony na Access Policy — KV musi być gotowy zanim zostanie sekret.
- Provider `random` nie wymaga konfiguracji, wystarczy że jest w `required_providers` w root module.


# 🏗️ Terraform - Moduły dla początkujących (Azure)

> Prosty przewodnik z jednym konkretnym przykładem od zera - na zasobach Azure.

## Po co w ogóle są moduły?

Wyobraź sobie, że budujesz infrastrukturę dla 3 środowisk: `dev`, `staging`, `prod`.

**Bez modułów** - kopiujesz ten sam kod 3 razy i modyfikujesz ręcznie. Gdy trzeba coś zmienić, zmieniasz w 3 miejscach. Łatwo o błąd.

**Z modułami** - piszesz kod raz, a wywołujesz go 3 razy z różnymi parametrami. Zmiana w jednym miejscu = zmiana wszędzie.

```
Moduł to jak funkcja w programowaniu:
piszesz ją raz → wywołujesz wielokrotnie z różnymi argumentami.
```

**Korzyści z modułów:**

- ♻️ **Reużywalność** - ten sam kod dla dev/staging/prod
- 🧹 **Porządek** - zamiast jednego gigantycznego `main.tf` masz logicznie podzielone kawałki
- 👥 **Współpraca** - różne zespoły mogą pracować na różnych modułach

> 📖 Źródło: https://developer.hashicorp.com/terraform/language/modules#overview

---

## Jak wygląda projekt BEZ modułów

Wszystko w jednym pliku - szybko robi się bałagan:

```
my-project/
└── main.tf        ← WSZYSTKO tutaj: resource group, sieć, VM, firewall...
```

```hcl
# main.tf - wszystko na kupie

resource "azurerm_resource_group" "main" {
  name     = "rg-myapp-dev"
  location = "West Europe"
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-myapp-dev"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "public" {
  name                 = "subnet-public"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_linux_virtual_machine" "web" {
  name                = "vm-web-dev"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  # ... i kolejne 200 linii poniżej ...
}
```

😬 Przy większym projekcie - niemożliwe do ogarnięcia.

---

## Jak wygląda projekt Z modułami

```
my-project/
├── main.tf              ← root module - tutaj tylko WYWOŁANIA modułów
├── variables.tf         ← zmienne root module
├── outputs.tf           ← outputy root module
├── terraform.tfvars     ← konkretne wartości zmiennych
│
└── modules/
    ├── vnet/            ← moduł odpowiedzialny za sieć (VNet + Subnet)
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── vm/              ← moduł odpowiedzialny za maszynę wirtualną
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

Root `main.tf` jest teraz czytelny - widać tylko co jest tworzone, bez zbędnych szczegółów:

```hcl
# main.tf (root) - czytelny, wysoko poziomowy

module "vnet" {
  source      = "./modules/vnet"
  environment = "dev"
  location    = "West Europe"
}

module "vm" {
  source              = "./modules/vm"
  resource_group_name = module.vnet.resource_group_name
  subnet_id           = module.vnet.subnet_id
}
```

---
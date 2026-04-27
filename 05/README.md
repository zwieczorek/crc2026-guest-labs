# Zadanie: Tworzenie Storage Account i kontenera kodem Terraform

## Cel

Napisz konfigurację Terraform, która tworzy **Azure Storage Account** oraz **Storage Container** w istniejącej grupie zasobów. Wszystkie zasoby definiujesz kodem — bez klikania w portalu.

## Struktura plików

| Plik | Zawartość |
|---|---|
| `providers.tf` | Konfiguracja providera `azurerm` i wersji Terraform |
| `data.tf` | Data source pobierający istniejącą Resource Group |
| `local.tf` | Lokalne zmienne (tagi) |
| `main.tf` | Zasoby do uzupełnienia: Storage Account + Container |

## Kroki

### 1. Uzupełnij `main.tf`

Utwórz zasób `azurerm_storage_account` z następującymi wymaganiami:

- SKU: `Standard` / `LRS`
- Kind: `StorageV2`
- `min_tls_version = "TLS1_2"`
- Publiczny dostęp sieciowy: włączony
- Versioning blobów: włączony
- Soft delete (blob i kontener): **7 dni**
- Tag `owner` — użyj lokalnej zmiennej z `local.tf`

Następnie utwórz zasób `azurerm_storage_container`:

- Typ dostępu: `private`
- Powiąż z utworzonym Storage Account przez `storage_account_id`

### 2. Zainicjuj i zastosuj konfigurację

```bash
terraform init
terraform plan
terraform apply
```

### 3. Zweryfikuj

Sprawdź, że kontener pojawił się w Storage Account:

```bash
az storage container list \
  --account-name <nazwa_storage_account> \
  --auth-mode login \
  --output table
```

## Wskazówki

- Nazwa Storage Account musi być **globalnie unikalna** (3–24 znaki, tylko małe litery i cyfry).
- Resource Group już istnieje — pobierz jej dane przez `data "azurerm_resource_group"`.

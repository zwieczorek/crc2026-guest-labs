# Zadanie: Tworzenie Key Vault, klucza i sekretu + migracja do remote backend

## Cel

Napisz konfigurację Terraform, która tworzy **Azure Key Vault** wraz z Access Policy, kluczem RSA i sekretem.
Wartość sekretu zostanie wygenerowana losowo przez provider `random` — bez wpisywania haseł ręcznie.

Ćwiczenie uczy też pracy z **remote backend**: po stworzeniu Key Vault przeniesiesz stan Terraform
do Storage Account i kontenera utworzonych w lab 05, a dopiero potem wdrożysz pozostałe zasoby.

Ćwiczenie składa się z 5 etapów, które należy wdrożyć w kolejności.

## Struktura plików

| Plik | Zawartość |
|---|---|
| `providers.tf` | Konfiguracja providerów `azurerm` i `random` |
| `data.tf` | Data source pobierający istniejącą Resource Group i dane bieżącego klienta |
| `local.tf` | Lokalne zmienne (tagi) |
| `main.tf` | Zasoby do uzupełnienia — 5 etapów |

## Etapy

### Etap 1 — Key Vault

Utwórz zasób `azurerm_key_vault` z wymaganiami:

- SKU: `standard`
- Soft delete: **7 dni**
- Purge protection: wyłączona (dla wygody w lab)
- Publiczny dostęp sieciowy: włączony
- `tenant_id` — pobierz z `data.azurerm_client_config.current`
- Tag `owner`

> Nazwa Key Vault musi być **globalnie unikalna** (3–24 znaki, litery, cyfry i myślniki).

Wdróż tylko ten zasób przed przejściem do kolejnego etapu:

```bash
terraform init
terraform apply
```

---

### Etap 2 — Migracja stanu do remote backend

Teraz, gdy Key Vault istnieje, przenieś stan Terraform do Storage Account i kontenera
utworzonych w **lab 05**.

Dodaj blok `backend` do `providers.tf`, wewnątrz bloku `terraform`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "<resource_group_z_lab05>"
    storage_account_name = "<nazwa_storage_account_z_lab05>"
    container_name       = "<nazwa_kontenera_z_lab05>"
    key                  = "lab06.terraform.tfstate"
  }

  # ... reszta bloku terraform bez zmian
}
```

Wykonaj migrację stanu:

```bash
terraform init -migrate-state
```

Terraform wykryje lokalny plik `terraform.tfstate` i zapyta, czy przenieść go do nowego backendu — potwierdź `yes`.

Zweryfikuj, że plik stanu pojawił się w kontenerze:

```bash
az storage blob list \
  --account-name <nazwa_storage_account_z_lab05> \
  --container-name <nazwa_kontenera_z_lab05> \
  --auth-mode login \
  --output table
```

---

### Etap 3 — Access Policy dla bieżącego użytkownika

Utwórz zasób `azurerm_key_vault_access_policy`, który nada bieżącemu użytkownikowi uprawnienia do kluczy i sekretów:

- `key_vault_id` — ID Key Vault z Etapu 1
- `tenant_id` i `object_id` — z `data.azurerm_client_config.current`
- `key_permissions` — przynajmniej:
  `Create`, `Delete`, `Get`, `List`, `Update`, `Purge`, `Recover`,
  `Decrypt`, `Encrypt`, `Sign`, `Verify`, `WrapKey`, `UnwrapKey`,
  `GetRotationPolicy`, `SetRotationPolicy`
- `secret_permissions` — przynajmniej: `Get`, `List`, `Set`, `Delete`, `Purge`, `Recover`

---

### Etap 4 — Klucz RSA

Utwórz zasób `azurerm_key_vault_key`:

- Typ: `RSA`, rozmiar: `2048`
- Operacje (`key_opts`): `decrypt`, `encrypt`, `sign`, `unwrapKey`, `verify`, `wrapKey`
- Data wygaśnięcia
- Dodaj `depends_on` na `azurerm_key_vault_access_policy.current_user` — klucz wymaga już nadanego dostępu

---

### Etap 5 — Losowe hasło i sekret

Zamiast wpisywać hasło ręcznie, wygeneruj je przy pomocy providera `random`.

1. Utwórz `random_password`:
   - Długość: `24` znaki
   - Znaki specjalne: włączone
   - `override_special = "!#$%&*()-_=+[]{}:?"`

2. Utwórz `azurerm_key_vault_secret`:
   - Wartość: wynik z `random_password`
   - Data wygaśnięcia: `2027-01-01T00:00:00Z`
   - Dodaj `depends_on` na `azurerm_key_vault_access_policy.current_user`

Wdróż pozostałe zasoby:

```bash
terraform apply
```

---

## Weryfikacja przez Azure CLI

### Sprawdź, że sekret istnieje

```bash
az keyvault secret list \
  --vault-name <nazwa_key_vault> \
  --output table
```

### Pobierz wartość sekretu

```bash
az keyvault secret show \
  --vault-name <nazwa_key_vault> \
  --name <nazwa_sekretu> \
  --query value \
  --output tsv
```

Powinnaś zobaczyć 24-znakowe hasło wygenerowane przez `random_password`.

### Sprawdź, że klucz RSA istnieje

```bash
az keyvault key list \
  --vault-name <nazwa_key_vault> \
  --output table
```

### Sprawdź szczegóły klucza (typ i datę wygaśnięcia)

```bash
az keyvault key show \
  --vault-name <nazwa_key_vault> \
  --name <nazwa_klucza> \
  --query "{type:key.kty, expires:attributes.expires}" \
  --output json
```

## Wersje pliku stanu w Azure Portal

Ponieważ Storage Account z lab 05 ma włączone **versioning blobów**, każdy `terraform apply` tworzy nową wersję pliku stanu. Możesz je przeglądać w portalu:

1. Otwórz **Azure Portal** → wyszukaj swój Storage Account z lab 05
2. Przejdź do **Data storage → Containers** i otwórz kontener z plikiem stanu
3. Kliknij na plik `lab06.terraform.tfstate`
4. Przejdź do zakładki **Versions** — zobaczysz listę wszystkich wersji z datą i rozmiarem
5. Kliknij dowolną wersję, aby pobrać lub podejrzeć jej zawartość

> Dzięki wersjom możesz przywrócić wcześniejszy stan Terraform w razie błędu — wystarczy pobrać starszą wersję pliku i zastąpić nią aktualny blob.

## Wskazówki

- Backend `azurerm` musi istnieć **przed** uruchomieniem `terraform init -migrate-state` — Storage Account i kontener z lab 05 muszą być już wdrożone.
- Provider `random` generuje wartość raz i zapisuje ją w stanie — przy kolejnym `apply` hasło się nie zmieni.
- Blok `features { key_vault { ... } }` w `providers.tf` pozwala na automatyczne usuwanie KV przy `destroy` bez konieczności ręcznego czyszczenia soft-delete.
- Rozwiązanie znajdziesz w folderze `../rozwiazanie/`.

# Lab 08 — Terraform CI/CD z GitHub Actions

---

## Część 1 — Przygotowanie repozytorium i pierwszego pipeline'u

### Krok 0 — Wdróż Storage Account

Wejdź do katalogu `05` i uruchom deployment storage accounta — będzie on przechowywał Terraform state file.

```bash
cd ../05
terraform apply
```

---

### Krok 1 — Utwórz repozytorium na GitHubie

1. Przejdź na [github.com](https://www.github.com) i zaloguj się na swoje konto (jeśli jeszcze nie masz konta, załóż je).
2. Stwórz **nowe, puste repozytorium**.

---

### Krok 2 — Dodaj sekrety do repozytorium

Przejdź do:
**Settings → Security and quality → Secrets and variables → Actions**

Dodaj następujące **Repository secrets** (wartości przekaże prowadzący):

| Secret | Opis |
|---|---|
| `ARM_CLIENT_ID` | Client ID Service Principala |
| `ARM_CLIENT_SECRET` | Client Secret Service Principala |
| `ARM_SUBSCRIPTION_ID` | ID subskrypcji Azure |
| `ARM_TENANT_ID` | ID tenanta Azure AD |

---

### Krok 3 — Utwórz środowisko z wymaganą akceptacją

W ustawieniach repozytorium przejdź do **Environments** i:

1. Stwórz nowe środowisko o nazwie **`production`**.
2. Zaznacz opcję **Required reviewers**.
3. Dodaj siebie jako wymaganego recenzenta i zapisz zmiany.

> Dzięki temu każdy `terraform apply` będzie wymagał ręcznego zatwierdzenia.

---

### Krok 4 — Sklonuj repozytorium i otwórz w IDE

Sklonuj nowo utworzone repozytorium lokalnie i otwórz je w IDE (wskazówki pojawią się po utworzeniu repo na GitHubie).

---

### Krok 5 — Utwórz pipeline deploy

Stwórz katalog `.github/workflows/` i wewnątrz plik **`deploy.yml`**.

Wzorcowy plik pipeline znajduje się w tym repozytorium pod ścieżką [.github/workflows/deploy.yml](.github/workflows/deploy.yml).

---

### Krok 6 — Utwórz pliki Terraform

Stwórz następujące pliki:

- **`providers.tf`** — skonfiguruj provider `azurerm` oraz backend `azurerm` (z hardkodowanymi wartościami na tym etapie). **Nie definiuj subskrypcji** — wartość zostanie pobrana z sekretu.
- **`data.tf`** — odczytaj swoją resource grupę za pomocą bloku `data`.
- **`variables.tf`** — zdefiniuj potrzebne zmienne.
- **`.gitignore`** — wzorcowy plik znajdziesz w tym repozytorium.

Przykładowy backend w `providers.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-crc2026-student-XXX-lab"
    storage_account_name = "nazwatwojegostorageaccounta"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
  resource_provider_registrations = "none"
}
```

---

### Krok 7 — Wypchnij zmiany i uruchom pipeline

```bash
git add .
git commit -m "Initial Terraform setup"
git push origin main
```

Przejdź do zakładki **Actions** na GitHubie i sprawdź, czy pipeline uruchomił się poprawnie.

---

## Część 2 — Wdrożenie Key Vaulta z sekretem

Stwórz konfigurację Terraform, która wdroży Key Vault wraz z wygenerowanym losowo sekretem.

Użyj następujących zasobów:

| Zasób | Opis |
|---|---|
| `azurerm_key_vault` | Key Vault |
| `azurerm_key_vault_access_policy` (x2) | Jedna dla Service Principala (`azurerm_client_config`), druga dla Twojego użytkownika |
| `azurerm_key_vault_key` | Klucz w Key Vault |
| `random_password` | Losowe hasło (patrz: zadanie 06) |
| `azurerm_key_vault_secret` | Sekret przechowywany w Key Vault |

### Zmienna dla object_id użytkownika

Dodaj w GitHubie **Repository variable** o nazwie `TF_VAR_USER_OBJECT_ID` z Twoim object ID.

W krokach `plan` i `apply` pipeline dodaj zmienną środowiskową:

```yaml
env:
  TF_VAR_user_object_id: ${{ vars.TF_VAR_USER_OBJECT_ID }}
```

### Deploy i weryfikacja

Wypchnij zmiany i wdróż zasoby przez pipeline. Po zakończeniu **sprawdź w portalu Azure**, czy sekret jest widoczny w Key Vault.

---

## Część 3 — Usunięcie hardkodowania backendu

Zastąp hardkodowane wartości backendu w `providers.tf`:

**Przed:**
```hcl
backend "azurerm" {
  resource_group_name  = "rg-crc2026-student-XXX-lab"
  storage_account_name = "sa_name"
  container_name       = "terraform"
  key                  = "terraform.tfstate"
}
```

**Po:**
```hcl
backend "azurerm" {}
```

### Dodaj Repository Variables na GitHubie

Dodaj następujące zmienne (**Settings → Secrets and variables → Actions → Variables**):

| Variable | Wartość |
|---|---|
| `BACKEND_RESOURCE_GROUP_NAME` | Nazwa resource grupy ze storage accountem |
| `BACKEND_STORAGE_ACCOUNT_NAME` | Nazwa storage accounta |
| `BACKEND_CONTAINER_NAME` | Nazwa kontenera (np. `terraform`) |
| `BACKEND_KEY` | Nazwa pliku state (np. `terraform.tfstate`) |

### Zaktualizuj komendę `terraform init` w pipeline

```yaml
- name: "Terraform Init"
  run: |
    terraform init -input=false -upgrade \
      -backend-config="resource_group_name=${{ vars.BACKEND_RESOURCE_GROUP_NAME }}" \
      -backend-config="storage_account_name=${{ vars.BACKEND_STORAGE_ACCOUNT_NAME }}" \
      -backend-config="container_name=${{ vars.BACKEND_CONTAINER_NAME }}" \
      -backend-config="key=${{ vars.BACKEND_KEY }}"
```

Wypchnij zmiany i sprawdź, czy pipeline działa poprawnie.

---

## Część 4 — Pipeline do usuwania zasobów (Terraform Destroy)

Stwórz nowy plik **`.github/workflows/destroy.yml`** bazując na `deploy.yml`.

### Zmiany względem deploy pipeline

1. **Wyzwalacz** — ustaw tylko `workflow_dispatch` (ręczne uruchomienie):

```yaml
on:
  workflow_dispatch:
```

2. **Terraform Plan** — zmień komendę na plan destroy:

```yaml
run: terraform plan -destroy -input=false -out=tfplan
```

3. **Nazwy jobów** — zmień `Terraform Plan` → `Terraform Destroy Plan`, `Terraform Apply` → `Terraform Destroy Apply`.

### Zaktualizuj deploy pipeline

Aby aktualizacja pliku `destroy.yml` nie wyzwalała deploy pipeline, dodaj do `deploy.yml`:

```yaml
name: "Terraform Deploy"
on:
  push:
    branches:
      - main
    paths-ignore:
      - .github/workflows/destroy.yml
```

### Uruchomienie destroy

Przejdź do **Actions → Terraform Destroy** i uruchom pipeline ręcznie (`Run workflow`).

---

## Cleanup — Usunięcie Storage Accounta

Po zakończeniu labów wejdź do katalogu `05` i usuń storage account komendą:

```bash
cd ../05
terraform destroy
```

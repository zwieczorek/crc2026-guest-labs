# 🎯 Cel

Celem tej części szkolenia jest zapoznanie uczestników z podstawowymi elementami **Terraform** oraz zrozumienie ich roli w zarządzaniu infrastrukturą jako kodem (Infrastructure as Code).

📌 Zakres szkolenia obejmuje:
- 🔧 **variables**
- 🧩 **locals**
- 📤 **outputs**
- 📦 **Terraform state file**
- ▶️ podstawowe komendy: `terraform init`, `terraform plan`, `terraform apply`

---

## 🔧 Variables

**Variables** (zmienne wejściowe) służą do parametryzowania konfiguracji Terraform.
Pozwalają przekazywać wartości z zewnątrz, takie jak środowisko, nazwy czy inne ustawienia, dzięki czemu ten sam kod może być używany w różnych kontekstach bez zmian w jego strukturze.

---

## 🧩 Locals

**Locals** (zmienne lokalne) służą do definiowania wartości pomocniczych wewnątrz konfiguracji Terraform.
Pomagają uprościć kod, poprawić jego czytelność oraz ograniczyć duplikację, często bazując na wartościach z variables.

---

## 📤 Outputs

**Outputs** umożliwiają zwracanie wybranych wartości po wykonaniu konfiguracji Terraform.
Są wykorzystywane do:
- podglądu istotnych informacji,
- przekazywania danych pomiędzy modułami,
- udostępniania wyników innym narzędziom lub zespołom.

---

## 📦 Terraform State File

**State file** to plik, w którym Terraform przechowuje aktualny stan infrastruktury.
Zawiera informacje o tym, jakie zasoby zostały utworzone oraz jak są one powiązane z kodem Terraform.

⚠️ State file jest kluczowy, ponieważ:
- umożliwia Terraformowi śledzenie zmian w infrastrukturze,
- pozwala planować różnice pomiędzy aktualnym a docelowym stanem,
- stanowi podstawę działania komend `plan` i `apply`.

---

## ▶️ Podstawowe komendy Terraform

### 🚀 terraform init

`terraform init` służy do zainicjalizowania projektu Terraform.
Przygotowuje środowisko do pracy, pobiera wymagane providery oraz konfiguruje backend dla state file.

---

### 🔍 terraform plan

`terraform plan` generuje plan zmian w infrastrukturze.
Pokazuje, jakie zasoby zostaną utworzone, zmodyfikowane lub usunięte, **bez wprowadzania rzeczywistych zmian**.

---

### ✅ terraform apply

`terraform apply` wykonuje zmiany opisane w konfiguracji Terraform.
Na podstawie planu tworzy, aktualizuje lub usuwa zasoby, a następnie aktualizuje state file.
# 🎯 Cel

Celem tej części szkolenia jest zapoznanie uczestników z:
- 🧾 blokiem **data** w Terraform,
- 🔌 mechanizmem działania **providerów**.

Szkolenie pozwala zrozumieć, w jaki sposób Terraform:
- korzysta z istniejących zasobów,
- komunikuje się z chmurami i innymi systemami,
- oddziela konfigurację zasobów od integracji z zewnętrznymi platformami.

---

## 🔌 Providery w Terraform

**Provider** to komponent Terraform odpowiedzialny za komunikację z konkretną platformą lub usługą, np.:
- chmurą publiczną (AWS, Azure, GCP),
- systemami zewnętrznymi (GitHub, Kubernetes).

---

## 🧾 Blok data (Data Sources)

**Blok `data`** służy do **odczytywania istniejących zasobów**

📌 Data sources pozwalają:
- pobierać informacje o istniejącej infrastrukturze,
- wykorzystywać je w nowych zasobach,
- integrować Terraform z już istniejącym środowiskiem.

📌 Ważne cechy:
- blok `data` **nie tworzy** zasobów,
- służy wyłącznie do odczytu,
- często wykorzystywany jest razem z providerami.

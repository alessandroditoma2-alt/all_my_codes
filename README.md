# 📊 Analisi Econometrica Difference-in-Differences

## Impatto del Conflitto Russia-Ucraina sul Settore Agroalimentare Italiano

Questo repository contiene script R completi per analizzare l'effetto causale del conflitto russo-ucraino (24 febbraio 2022) su salari, occupazione e produttività delle imprese agroalimentari italiane utilizzando la metodologia **Difference-in-Differences (DiD)**.

---

## 📁 Contenuto del Repository

### 🔧 Script Principali

| File | Descrizione |
|------|-------------|
| **`did_analisi_russia_ucraina_agroalimentare.R`** | **Script principale** - Analisi DiD completa con grafici e tabelle |
| **`genera_dati_esempio.R`** | Genera dataset simulato per testare l'analisi |
| **`test_installazione.R`** | Verifica configurazione ambiente R e librerie |

### 📚 Documentazione

| File | Descrizione |
|------|-------------|
| **`README_ANALISI_DID.md`** | Documentazione tecnica completa (metodologia, interpretazione, troubleshooting) |
| **`GUIDA_RAPIDA.md`** | Guida quick start per iniziare in 5 minuti |
| **`README.md`** | Questo file - Panoramica del progetto |

### 📊 Script Legacy

| File | Descrizione |
|------|-------------|
| `data_cleaning` | Workflow pulizia dati in R (script generico) |
| `md` | Codice Stata per analisi platform workers (progetto precedente) |

---

## 🎯 Obiettivi dell'Analisi

### 📈 Analisi 1: Agroalimentare vs Altri Settori Manifatturieri

**Domanda di ricerca**: Il settore agroalimentare è stato più colpito dal conflitto rispetto ad altri settori?

- **Treatment**: ATECO 10 (Alimentare) + ATECO 11 (Bevande)
- **Control**: ATECO 13-18, 22, 25 (Tessile, abbigliamento, pelle, legno, carta, stampa, gomma, metalli)
- **Razionale**: Il settore agroalimentare dipende maggiormente da materie prime (grano, olio di semi, fertilizzanti) provenienti da Russia/Ucraina

### 📊 Analisi 2: Alimentare vs Bevande

**Domanda di ricerca**: All'interno del settore agroalimentare, chi è stato più colpito?

- **Treatment**: ATECO 10 (Alimentare)
- **Control**: ATECO 11 (Bevande)
- **Razionale**: Il settore alimentare è più esposto a shock di commodity rispetto alle bevande

### 📉 Variabili Analizzate

1. **Salari** (Costo del lavoro totale)
2. **Occupazione** (Numero di dipendenti)
3. **Produttività** (Valore Aggiunto / Dipendenti)

---

## 🚀 Quick Start

### 1️⃣ Prerequisiti

- **R** (versione ≥ 4.0): https://cran.r-project.org/
- **RStudio** (consigliato): https://posit.co/download/rstudio-desktop/

### 2️⃣ Verifica Installazione

```r
# Apri RStudio, imposta la directory di lavoro e verifica l'ambiente
source("test_installazione.R")
```

### 3️⃣ Test con Dati Simulati

```r
# Genera dati di esempio (simula database AIDA 2017-2024)
source("genera_dati_esempio.R")

# Esegui l'analisi DiD completa
source("did_analisi_russia_ucraina_agroalimentare.R")

risultati <- esegui_analisi_completa(
  file_path = "dati/database_aida_simulato.xlsx"
)
```

### 4️⃣ Analisi con Dati Reali (AIDA)

```r
# Quando hai il database AIDA reale
risultati <- esegui_analisi_completa(
  file_path = "path/to/database_aida_reale.xlsx",
  sheet_name = "Dati"  # Opzionale
)
```

---

## 📊 Output Generati

L'analisi crea automaticamente:

```
output/
├── tabelle/
│   ├── analisi1_did_base.html              # Risultati DiD Analisi 1 (OLS)
│   ├── analisi1_did_fixed_effects.html     # Risultati DiD Analisi 1 (FE)
│   ├── analisi2_did_base.html              # Risultati DiD Analisi 2 (OLS)
│   └── analisi2_did_fixed_effects.html     # Risultati DiD Analisi 2 (FE)
├── grafici/
│   ├── analisi1_parallel_trends_*.png      # Verifica assunzioni DiD
│   ├── analisi1_event_study_*.png          # Effetti dinamici nel tempo
│   ├── analisi2_parallel_trends_*.png
│   └── analisi2_event_study_*.png
└── dati_preparati/
    ├── dataset_did_preparato.rds           # Dataset preparato (R)
    └── dataset_did_preparato.csv           # Dataset preparato (CSV)
```

---

## 📈 Interpretazione Risultati

### 🔑 Coefficiente Chiave: `Treatment × Post`

Questo coefficiente rappresenta l'**effetto causale** del conflitto.

**Esempio di tabella risultati:**

```
                          Log(Costo Lavoro)
Treatment × Post            -0.067***
                            (0.018)
---
N                          15,432
R²                          0.652
```

**Interpretazione**: Il conflitto russo-ucraino ha causato una **riduzione del 6.7%** nel costo del lavoro delle imprese agroalimentari rispetto agli altri settori manifatturieri. L'effetto è altamente significativo (p < 0.01).

### ✅ Validazione: Parallel Trends

**Verifica visiva**: I grafici `parallel_trends_*.png` devono mostrare trend paralleli **prima del 2022**.

- ✅ **Trend paralleli** → Assunzione DiD soddisfatta, risultati validi
- ❌ **Trend divergenti** → Assunzione violata, risultati non validi

---

## 🛠️ Struttura Dati Richiesta

Il file Excel AIDA deve contenere:

| Variabile | Tipo | Descrizione |
|-----------|------|-------------|
| `anno` | Numerico | Anno di riferimento (2017-2024) |
| `id_azienda` | Carattere | Identificativo univoco azienda |
| `ateco_2` | Numerico | Codice ATECO a 2 cifre |
| `costo_lavoro` | Numerico | Costo totale del lavoro (€) |
| `dipendenti` | Numerico | Numero di dipendenti (fine anno) |
| `valore_aggiunto` | Numerico | Valore aggiunto (€) |

**Nota**: I nomi delle variabili possono essere adattati modificando la funzione `prepara_dati_did()` nello script principale.

---

## 📚 Metodologia

### Modello Difference-in-Differences

Il modello base stima:

$$Y_{it} = \beta_0 + \beta_1 \cdot Treatment_i + \beta_2 \cdot Post_t + \beta_3 \cdot (Treatment_i \times Post_t) + \varepsilon_{it}$$

Dove:
- $Y_{it}$: Outcome (salari, occupazione, produttività)
- $Treatment_i$: 1 se azienda nel gruppo treatment, 0 altrimenti
- $Post_t$: 1 se anno ≥ 2022, 0 altrimenti
- $\beta_3$: **Effetto causale (ATT)**

### Assunzioni Critiche

1. **Parallel Trends**: Treatment e control avrebbero avuto trend identici senza il conflitto
2. **No Anticipazione**: Le imprese non hanno modificato il comportamento prima del 24/02/2022
3. **Composizione Stabile**: Le caratteristiche delle imprese sono relativamente stabili
4. **SUTVA**: Nessun spillover tra gruppi

---

## 🔧 Personalizzazione

### Modificare Settori ATECO

```r
# Nella sezione CONFIGURAZIONE dello script principale
ATECO_TREATMENT_1 <- c(10, 11)           # Modifica qui
ATECO_CONTROL_1   <- c(13, 14, 15, ...)  # Modifica qui
```

### Cambiare Data Trattamento

```r
TRATTAMENTO_DATA <- as.Date("2022-02-24")  # Cambia questa data
TRATTAMENTO_ANNO <- 2022
```

### Aggiungere Covariates di Controllo

Modificare le funzioni `stima_did()` e `stima_did_fe()` per includere variabili di controllo (es. dimensione azienda, regione, fatturato).

---

## 📦 Dipendenze R

```r
install.packages(c(
  "tidyverse",      # Manipolazione dati
  "readxl",         # Lettura Excel
  "lubridate",      # Date
  "broom",          # Tidy model output
  "stargazer",      # Regression tables
  "ggplot2",        # Grafici
  "scales",         # Formattazione
  "fixest",         # Regressioni efficienti
  "modelsummary",   # Tabelle moderne
  "kableExtra",     # Formattazione tabelle
  "haven",          # Import/export dati
  "janitor"         # Pulizia nomi
))
```

Lo script installa automaticamente i pacchetti mancanti.

---

## 🔍 Estensioni Possibili

1. **Placebo Tests**: Date false di trattamento per verificare robustezza
2. **Eterogeneità**: Effetti diversi per dimensione azienda, regione, export
3. **Propensity Score Matching**: Pre-processare per migliorare comparabilità
4. **Synthetic Control**: Metodo alternativo per costruire il controllo
5. **Callaway-Sant'Anna**: DiD con trattamenti sfalsati nel tempo

---

## 📖 Riferimenti Bibliografici

- **Angrist & Pischke (2009)**: *Mostly Harmless Econometrics* - Capitolo 5 (DiD)
- **Bertrand, Duflo & Mullainathan (2004)**: "How Much Should We Trust DiD Estimates?" *QJE*
- **Callaway & Sant'Anna (2021)**: "DiD with Multiple Time Periods" *Journal of Econometrics*

---

## 👤 Autore

**Alessandro Di Toma**  
Master Thesis - Analisi dell'Impatto Economico del Conflitto Russo-Ucraino

---

## 📄 Licenza

Questo codice è fornito "as is" per scopi di ricerca accademica.

---

## 🆘 Supporto

- **Documentazione completa**: Vedi `README_ANALISI_DID.md`
- **Quick start**: Vedi `GUIDA_RAPIDA.md`
- **Test ambiente**: Eseguire `source("test_installazione.R")`

---

## ✨ Caratteristiche

- ✅ Analisi DiD completa con 2 confronti (agroalimentare vs altri, alimentare vs bevande)
- ✅ Modelli OLS e Fixed Effects (azienda + anno)
- ✅ Verifica automatica parallel trends con grafici
- ✅ Event study per effetti dinamici
- ✅ Tabelle risultati formattate in HTML
- ✅ Grafici publication-ready (PNG 300dpi)
- ✅ Dataset simulato per testare l'analisi
- ✅ Codice ben commentato e modulare
- ✅ Installazione automatica dipendenze
- ✅ Documentazione completa in italiano

---

**Pronto per l'analisi della tua tesi! 🎓📊**

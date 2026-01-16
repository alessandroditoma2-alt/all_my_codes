# 🚀 Comandi Rapidi - Cheat Sheet

## Setup Iniziale

```r
# 1. Impostare directory di lavoro
setwd("/percorso/del/progetto")

# 2. Verificare ambiente
source("test_installazione.R")
```

## Test con Dati Simulati

```r
# 1. Generare dati di esempio
source("genera_dati_esempio.R")

# 2. Eseguire analisi completa
source("did_analisi_russia_ucraina_agroalimentare.R")
risultati <- esegui_analisi_completa("dati/database_aida_simulato.xlsx")
```

## Analisi con Dati Reali

```r
# Caricare script principale
source("did_analisi_russia_ucraina_agroalimentare.R")

# Eseguire analisi con dati AIDA
risultati <- esegui_analisi_completa(
  file_path = "path/to/database_aida.xlsx",
  sheet_name = "Dati"  # Opzionale
)
```

## Visualizzare Risultati

```r
# Modello specifico
summary(risultati$analisi_1$modelli_fe$log_costo_lavoro)

# Coefficiente DiD
coef(risultati$analisi_1$modelli_fe$log_costo_lavoro)["treat_post_1"]

# Dati preparati
View(risultati$dati)
```

## Analisi di Robustezza

```r
# Caricare funzioni avanzate
source("esempi_avanzati.R")

# Placebo test
modello_placebo <- placebo_test(risultati$dati, "log_costo_lavoro", anno_placebo = 2020)

# Test pre-trend
test_pretrend <- test_pre_trend(risultati$dati, "log_costo_lavoro")

# Senza outlier
modelli_outlier <- did_senza_outlier(risultati$dati, "log_costo_lavoro")

# Per sub-gruppi
sub_dim <- analisi_subgruppo(risultati$dati, "log_costo_lavoro", "dimensione")

# Robustezza completa
esegui_analisi_robustezza_completa(risultati, "log_costo_lavoro")
```

## Grafici Personalizzati

```r
# Parallel trends
grafico_parallel_trends(
  risultati$dati, 
  "log_costo_lavoro", 
  analisi_id = 1,
  save_path = "mio_grafico.png"
)

# Event study
modello_es <- stima_event_study(risultati$dati, "log_costo_lavoro", analisi_id = 1)
grafico_event_study(modello_es, save_path = "event_study.png")
```

## Export e Tabelle

```r
# Tabella HTML
library(modelsummary)
modelsummary(
  risultati$analisi_1$modelli_fe,
  output = "tabella.html"
)

# Tabella LaTeX
library(stargazer)
stargazer(
  risultati$analisi_1$modelli_fe$log_costo_lavoro,
  type = "latex",
  out = "tabella.tex"
)
```

## Modifiche Comuni

### Cambiare Data Trattamento

```r
# Nel file did_analisi_russia_ucraina_agroalimentare.R
TRATTAMENTO_DATA <- as.Date("2022-02-24")  # Modificare qui
TRATTAMENTO_ANNO <- 2022
```

### Cambiare Settori ATECO

```r
# Nel file did_analisi_russia_ucraina_agroalimentare.R
ATECO_TREATMENT_1 <- c(10, 11)  # Modificare qui
ATECO_CONTROL_1   <- c(13, 14, 15, 16, 17, 18, 22, 25)  # Modificare qui
```

### Adattare Nomi Variabili

```r
# Nella funzione prepara_dati_did()
df_prep <- df %>%
  rename(
    anno = year,                    # Se si chiama "year"
    costo_lavoro = salari_totali,   # Se si chiama "salari_totali"
    dipendenti = num_dipendenti     # Se si chiama "num_dipendenti"
  )
```

## Diagnostica Problemi

```r
# Verificare struttura dati
str(risultati$dati)
head(risultati$dati)

# Contare osservazioni per gruppo
risultati$dati %>%
  group_by(treatment_1, post) %>%
  summarise(n = n())

# Verificare valori mancanti
colSums(is.na(risultati$dati))

# Statistiche descrittive
summary(risultati$dati)
```

## Workflow Completo

```r
# Esegui tutto in un colpo solo
source("workflow_completo_esempio.R")
```

## Installazione Dipendenze

```r
# Installare tutte le librerie necessarie
install.packages(c(
  "tidyverse", "readxl", "lubridate", "broom", "stargazer",
  "ggplot2", "scales", "fixest", "modelsummary", 
  "kableExtra", "haven", "janitor"
))
```

## Output Locations

```
output/
├── tabelle/          # Tabelle HTML e LaTeX
├── grafici/          # Grafici PNG
└── dati_preparati/   # Dataset preparati

dati/
└── *.xlsx            # Dati simulati o reali
```

## Interpretazione Rapida

### Coefficiente DiD

```
Coefficiente = -0.067  →  -6.7% di variazione
Coefficiente =  0.052  →  +5.2% di variazione
```

### Significatività

```
*** → p < 0.01  (altamente significativo)
**  → p < 0.05  (significativo)
*   → p < 0.10  (debolmente significativo)
    → p ≥ 0.10  (non significativo)
```

## Formule Chiave

### DiD Base
```
Y = β0 + β1*Treatment + β2*Post + β3*Treatment×Post + ε
```

### DiD Fixed Effects
```
Y = β3*Treatment×Post + FE_azienda + FE_anno + ε
```

---

**Per aiuto completo**: Vedi `README_ANALISI_DID.md`  
**Per tutorial**: Vedi `GUIDA_RAPIDA.md`  
**Per esempi**: Esegui `workflow_completo_esempio.R`

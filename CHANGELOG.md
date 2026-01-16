# Changelog

Tutte le modifiche importanti al progetto sono documentate in questo file.

## [2024-01-16] - Implementazione Analisi DiD Conflitto Russia-Ucraina

### ✨ Nuove Funzionalità

#### Script Principali
- **`did_analisi_russia_ucraina_agroalimentare.R`**: Script completo per analisi Difference-in-Differences
  - Caricamento automatico dati da Excel (database AIDA)
  - Preparazione dataset con variabili treatment/control
  - Stima modelli DiD con OLS e Fixed Effects
  - Verifica parallel trends con grafici automatici
  - Event study per effetti dinamici
  - Export tabelle HTML professionali
  - Grafici publication-ready (PNG 300dpi)

- **`genera_dati_esempio.R`**: Generatore di dataset simulato
  - Simula database AIDA con 500 aziende (2017-2024)
  - Effetti realistici del conflitto incorporati nei dati
  - Settori ATECO: 10, 11, 13-18, 22, 25
  - Export in formato Excel, CSV, RDS
  - Grafici preliminari dei trend

- **`esempi_avanzati.R`**: Estensioni e analisi di robustezza
  - Placebo tests con date false
  - Test formale pre-trend
  - Analisi per sub-gruppi (dimensione, regione)
  - Modelli con covariates di controllo
  - Rimozione outlier
  - Export LaTeX per tesi

- **`workflow_completo_esempio.R`**: Workflow end-to-end
  - Dimostrazione completa dall'inizio alla fine
  - Generazione dati → Analisi → Robustezza → Export
  - Riepilogo esecutivo automatico
  - Interpretazione guidata dei risultati

- **`test_installazione.R`**: Verifica ambiente R
  - Test versione R
  - Verifica librerie installate
  - Test caricamento pacchetti
  - Test scrittura file
  - Diagnostica memoria

#### Documentazione
- **`README.md`**: Documentazione principale del progetto
  - Panoramica obiettivi e metodologia
  - Quick start guide
  - Struttura dati richiesta
  - Interpretazione risultati
  - Lista completa output generati

- **`README_ANALISI_DID.md`**: Documentazione tecnica dettagliata
  - Spiegazione metodologia DiD
  - Requisiti e dipendenze
  - Interpretazione coefficienti
  - Validazione assunzioni
  - Troubleshooting completo
  - Riferimenti bibliografici

- **`GUIDA_RAPIDA.md`**: Quick start (5 minuti)
  - Setup rapido
  - Comandi essenziali
  - Interpretazione base
  - Personalizzazioni comuni
  - Problemi frequenti

#### Configurazione
- **`.gitignore`**: File di esclusione Git
  - Ignore file output (tabelle, grafici, dati)
  - Ignore file temporanei R
  - Preserva struttura directory

- **`LICENSE`**: Licenza MIT

- **`CHANGELOG.md`**: Questo file

### 📊 Analisi Implementate

1. **Analisi 1**: Agroalimentare (ATECO 10+11) vs Altri Manifatturieri (13-18, 22, 25)
   - Outcome: Salari, Occupazione, Produttività
   - Modelli: OLS e Fixed Effects (azienda + anno)

2. **Analisi 2**: Alimentare (ATECO 10) vs Bevande (ATECO 11)
   - Outcome: Salari, Occupazione, Produttività
   - Modelli: OLS e Fixed Effects

3. **Analisi di Robustezza**:
   - Placebo tests
   - Pre-trend formale
   - Rimozione outlier
   - Sub-gruppi (dimensione, regione)
   - Event study (effetti dinamici)

### 📦 Dipendenze R

Pacchetti richiesti (installazione automatica):
- tidyverse (manipolazione dati)
- readxl (lettura Excel)
- lubridate (gestione date)
- broom (tidy model output)
- stargazer (tabelle regressione)
- ggplot2 (grafici)
- scales (formattazione)
- fixest (regressioni efficienti)
- modelsummary (tabelle moderne)
- kableExtra (formattazione HTML)
- haven (import/export dati)
- janitor (pulizia nomi variabili)

### 📁 Struttura Output

```
output/
├── tabelle/
│   ├── analisi1_did_base.html
│   ├── analisi1_did_fixed_effects.html
│   ├── analisi2_did_base.html
│   ├── analisi2_did_fixed_effects.html
│   ├── robustezza_completa.html
│   └── tabella_tesi_principale.tex
├── grafici/
│   ├── analisi1_parallel_trends_*.png
│   ├── analisi1_event_study_*.png
│   ├── analisi2_parallel_trends_*.png
│   └── analisi2_event_study_*.png
└── dati_preparati/
    ├── dataset_did_preparato.rds
    └── dataset_did_preparato.csv

dati/
├── database_aida_simulato.xlsx
├── database_aida_simulato.csv
├── database_aida_simulato.rds
├── preview_trend_occupazione.png
└── preview_trend_costo_lavoro.png
```

### 🔧 Caratteristiche Tecniche

- **Modularità**: Funzioni riutilizzabili e ben documentate
- **Automazione**: Installazione automatica dipendenze
- **Robustezza**: Gestione errori e validazione input
- **Flessibilità**: Parametri configurabili
- **Documentazione**: Commenti estensivi in italiano
- **Riproducibilità**: Seed fisso per simulazioni
- **Performance**: Utilizzo di fixest per regressioni efficienti
- **Visualizzazione**: Grafici professionali con ggplot2

### 📚 Metodologia

- **Difference-in-Differences (DiD)**: Stima effetti causali
- **Fixed Effects**: Controllo caratteristiche non osservate
- **Cluster Standard Errors**: Correzione autocorrelazione
- **Event Study**: Analisi effetti dinamici temporali
- **Parallel Trends**: Verifica assunzione fondamentale
- **Placebo Tests**: Validazione robustezza risultati

### 🎯 Obiettivi Raggiunti

- ✅ Script R completo funzionante
- ✅ Caricamento dati da Excel (AIDA)
- ✅ Regressioni DiD stimate correttamente
- ✅ Verifica parallel trends con grafici
- ✅ Tabelle risultati formattate (HTML + LaTeX)
- ✅ Grafici publication-ready (PNG 300dpi)
- ✅ Event study per effetti dinamici
- ✅ Analisi di robustezza complete
- ✅ Dataset simulato per testing
- ✅ Documentazione completa in italiano
- ✅ Workflow esempio end-to-end
- ✅ Codice ben commentato e riutilizzabile
- ✅ Export formato tesi (LaTeX)

### 📖 Riferimenti

- Angrist, J. D., & Pischke, J. S. (2009). *Mostly Harmless Econometrics*
- Bertrand, M., Duflo, E., & Mullainathan, S. (2004). "How Much Should We Trust DiD Estimates?" *QJE*
- Callaway, B., & Sant'Anna, P. H. (2021). "DiD with Multiple Time Periods" *Journal of Econometrics*

### 🔄 Note di Compatibilità

- Richiede R >= 4.0
- Testato su sistemi Unix/Linux
- Compatibile con Windows e macOS
- I file legacy (`data_cleaning`, `md`) sono stati preservati senza modifiche

---

**Autore**: Alessandro Di Toma  
**Progetto**: Master Thesis - Analisi Impatto Conflitto Russia-Ucraina  
**Data**: 16 Gennaio 2024

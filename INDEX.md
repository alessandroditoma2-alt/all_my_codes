# 📑 Indice del Progetto

## 🎯 Dove Iniziare?

### Se è la tua prima volta:
1. 📖 Leggi **`GUIDA_RAPIDA.md`** (5 minuti)
2. ▶️ Esegui **`test_installazione.R`** per verificare l'ambiente
3. 🧪 Esegui **`workflow_completo_esempio.R`** per vedere tutto in azione

### Se hai già familiarità con DiD:
1. ⚡ Consulta **`COMANDI_RAPIDI.md`** per i comandi essenziali
2. 🔬 Usa **`did_analisi_russia_ucraina_agroalimentare.R`** per l'analisi
3. 📊 Aggiungi analisi custom con **`esempi_avanzati.R`**

---

## 📚 Documentazione

| File | Scopo | Quando Usarlo |
|------|-------|---------------|
| **README.md** | Panoramica del progetto | Prima volta nel progetto |
| **GUIDA_RAPIDA.md** | Quick start (5 min) | Per iniziare subito |
| **README_ANALISI_DID.md** | Documentazione tecnica completa | Per approfondimenti metodologici |
| **COMANDI_RAPIDI.md** | Cheat sheet comandi | Durante l'analisi |
| **CHANGELOG.md** | Storia delle modifiche | Per vedere cosa è stato implementato |
| **INDEX.md** | Questo file - Guida alla navigazione | Quando sei perso! |

---

## 🔬 Script di Analisi

### Script Principali

| File | Descrizione | Utilizzo Tipico |
|------|-------------|-----------------|
| **did_analisi_russia_ucraina_agroalimentare.R** | 🌟 **SCRIPT PRINCIPALE** - Analisi DiD completa | `source("did_analisi_russia_ucraina_agroalimentare.R")`<br>`risultati <- esegui_analisi_completa("dati.xlsx")` |
| **genera_dati_esempio.R** | Genera dataset simulato per testing | `source("genera_dati_esempio.R")` |
| **esempi_avanzati.R** | Analisi di robustezza e estensioni | `source("esempi_avanzati.R")`<br>`placebo_test(...)` |
| **workflow_completo_esempio.R** | Workflow end-to-end completo | `source("workflow_completo_esempio.R")` |
| **test_installazione.R** | Verifica ambiente e dipendenze | `source("test_installazione.R")` |

### Funzioni Chiave per Script

#### `did_analisi_russia_ucraina_agroalimentare.R`
```r
esegui_analisi_completa(file_path)     # Esegue tutto
carica_dati_aida(file_path)            # Carica Excel
prepara_dati_did(df)                   # Prepara dataset
stima_did(df, outcome, treatment)      # Stima DiD base
stima_did_fe(df, outcome, treatment)   # Stima DiD con FE
grafico_parallel_trends(df, outcome)   # Verifica parallel trends
stima_event_study(df, outcome)         # Event study
```

#### `esempi_avanzati.R`
```r
placebo_test(df, outcome, anno_placebo)           # Placebo test
test_pre_trend(df, outcome)                       # Test formale pre-trend
did_senza_outlier(df, outcome)                    # Rimuovi outlier
analisi_subgruppo(df, outcome, gruppo_var)        # Eterogeneità
tabella_robustezza(modelli_lista)                 # Tabella comparativa
esegui_analisi_robustezza_completa(risultati)     # Tutto insieme
```

---

## 🗂️ Struttura del Progetto

```
progetto/
│
├── 📄 DOCUMENTAZIONE
│   ├── README.md                          # Panoramica progetto
│   ├── GUIDA_RAPIDA.md                    # Quick start
│   ├── README_ANALISI_DID.md              # Documentazione tecnica
│   ├── COMANDI_RAPIDI.md                  # Cheat sheet
│   ├── CHANGELOG.md                       # Storia modifiche
│   └── INDEX.md                           # Questo file
│
├── 🔬 SCRIPT R
│   ├── did_analisi_russia_ucraina_agroalimentare.R  # ⭐ PRINCIPALE
│   ├── genera_dati_esempio.R              # Genera dati test
│   ├── esempi_avanzati.R                  # Robustezza
│   ├── workflow_completo_esempio.R        # Workflow completo
│   └── test_installazione.R               # Verifica setup
│
├── 📂 DATI (creati durante esecuzione)
│   └── dati/
│       ├── database_aida_simulato.xlsx
│       ├── database_aida_simulato.csv
│       └── *.png (preview grafici)
│
├── 📊 OUTPUT (creati durante analisi)
│   └── output/
│       ├── tabelle/                       # HTML e LaTeX
│       ├── grafici/                       # PNG 300dpi
│       └── dati_preparati/                # RDS e CSV
│
├── 🗂️ LEGACY (file preesistenti)
│   ├── data_cleaning                      # Script pulizia dati
│   └── md                                 # Codice Stata precedente
│
└── ⚙️ CONFIGURAZIONE
    ├── .gitignore                         # File da ignorare
    └── LICENSE                            # Licenza MIT
```

---

## 🎓 Flusso di Lavoro Consigliato

### Per Tesi con Dati Simulati (Test)

```
1. test_installazione.R
   ↓
2. genera_dati_esempio.R
   ↓
3. did_analisi_russia_ucraina_agroalimentare.R
   ↓
4. Verifica grafici parallel trends
   ↓
5. esempi_avanzati.R (robustezza)
   ↓
6. workflow_completo_esempio.R (tutto insieme)
```

### Per Tesi con Dati Reali AIDA

```
1. test_installazione.R
   ↓
2. Preparare file Excel AIDA
   ↓
3. Adattare nomi variabili (se necessario)
   ↓
4. esegui_analisi_completa("dati_reali.xlsx")
   ↓
5. Verificare parallel trends ⚠️ CRITICO
   ↓
6. Se OK → Interpretare risultati
   Se NO → Cambiare gruppo controllo o metodo
   ↓
7. Analisi robustezza (esempi_avanzati.R)
   ↓
8. Export per tesi (LaTeX/HTML)
```

---

## 🚨 Troubleshooting Rapido

| Problema | Soluzione | Dettagli |
|----------|-----------|----------|
| Librerie mancanti | `test_installazione.R` | Installa automaticamente |
| Errore "variabile non trovata" | Adatta nomi in `prepara_dati_did()` | Vedi README_ANALISI_DID.md § "Personalizzazione" |
| Parallel trends violati | Cambia gruppo controllo | Risultati NON validi se violati |
| Coefficiente non significativo | Verifica campione e periodo | Forse effetto realmente zero |
| File Excel non si carica | Controlla percorso e formato | Usa `readxl::excel_sheets()` |

---

## 📊 Interpretare i Risultati

### Dove Trovare i Risultati?

1. **Tabelle**: `output/tabelle/*.html` (aprire nel browser)
2. **Grafici**: `output/grafici/*.png` (aprire con visualizzatore)
3. **Dati**: `output/dati_preparati/*.csv` (aprire con Excel/R)
4. **Console R**: Output di `summary(modello)`

### Cosa Cercare?

- ✅ **Coefficiente `Treatment × Post`**: Effetto del conflitto
- ✅ **P-value < 0.05**: Statisticamente significativo
- ✅ **Parallel trends paralleli**: Assunzione valida
- ✅ **Event study piatto pre-2022**: Nessun pre-trend

---

## 📞 Aiuto e Supporto

### Per Problemi Tecnici:
1. Consulta **`README_ANALISI_DID.md`** § Troubleshooting
2. Verifica ambiente con **`test_installazione.R`**
3. Controlla esempi in **`workflow_completo_esempio.R`**

### Per Domande Metodologiche:
1. Leggi **`README_ANALISI_DID.md`** § "Metodologia DiD"
2. Consulta riferimenti bibliografici nel README
3. Esamina i commenti nel codice (molto dettagliati!)

### Per Personalizzazioni:
1. Vedi **`COMANDI_RAPIDI.md`** § "Modifiche Comuni"
2. Studia **`esempi_avanzati.R`** per estensioni
3. Adatta funzioni in script principale

---

## 🎯 Obiettivi del Progetto

- [x] Analisi DiD completa e automatizzata
- [x] Caricamento dati da Excel (AIDA)
- [x] Verifica parallel trends con grafici
- [x] Modelli OLS e Fixed Effects
- [x] Event study per effetti dinamici
- [x] Analisi di robustezza complete
- [x] Export tabelle (HTML + LaTeX)
- [x] Grafici publication-ready
- [x] Dataset simulato per testing
- [x] Documentazione completa italiano
- [x] Codice riutilizzabile e ben commentato

---

## 📖 Riferimenti Rapidi

### Librerie R Utilizzate
- `tidyverse` - Manipolazione dati
- `fixest` - Regressioni efficienti
- `ggplot2` - Grafici professionali
- `modelsummary` - Tabelle moderne
- `readxl` - Lettura Excel

### Metodi Statistici
- **Difference-in-Differences (DiD)**: Stima effetti causali
- **Fixed Effects**: Controllo eterogeneità non osservata
- **Event Study**: Analisi dinamica temporale
- **Cluster Standard Errors**: Robustezza autocorrelazione

### File Importanti
- **Script principale**: `did_analisi_russia_ucraina_agroalimentare.R`
- **Dati esempio**: `dati/database_aida_simulato.xlsx`
- **Output**: `output/tabelle/` e `output/grafici/`

---

## ✨ Caratteristiche Speciali

- 🚀 **Automatizzazione completa**: Un comando per tutto
- 📊 **Grafici professionali**: Publication-ready 300dpi
- 🔍 **Validazione integrata**: Parallel trends automatici
- 💪 **Robustezza**: Placebo, pre-trend, outlier
- 📚 **Documentazione estensiva**: Tutto in italiano
- 🧪 **Testing integrato**: Dataset simulato incluso
- 📝 **Export flessibile**: HTML, LaTeX, CSV, RDS
- 🎓 **Pronto per tesi**: Tabelle e grafici formattati

---

**Buon lavoro con la tua tesi! 🎓📊**

---

_Ultima modifica: 16 Gennaio 2024_  
_Autore: Alessandro Di Toma_  
_Progetto: Master Thesis - Impatto Conflitto Russia-Ucraina_

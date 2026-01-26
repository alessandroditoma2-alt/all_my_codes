# 📊 Script R per Analisi Dati ISTAT - Ricerca e Sviluppo

Questo repository contiene script R per scaricare, analizzare e visualizzare i dati ISTAT sulla **spesa per ricerca e sviluppo intra-muros (% sul PIL)** per l'Italia.

## 📁 Struttura del Progetto

```
/home/engine/project/
├── R_scripts/
│   ├── istat_ricerca_sviluppo.R      # Script completo con analisi avanzata
│   └── download_rapido.R              # Script veloce per download e analisi base
├── data/                              # Dataset scaricati e puliti
├── output/
│   ├── plots/                         # Grafici e visualizzazioni
│   ├── statistiche_riassuntive.csv   # Statistiche complete
│   └── report_analisi_rd.html        # Report finale
└── README.md                          # Questo file
```

## 🎯 Obiettivi

Gli script permettono di:

1. **Scaricare dati ISTAT** sulla spesa R&D (% PIL) usando l'API ufficiale
2. **Esplorare i dati** con statistiche descrittive e controllo qualità
3. **Creare visualizzazioni** professionali della serie storica
4. **Analizzare trend** e variazioni nel tempo
5. **Eseguire analisi avanzate** di serie temporali
6. **Esportare risultati** in formati multipli

## 🚀 Come Utilizzare

### Opzione 1: Script Completo (Consigliato)

```r
# Esegui lo script completo in R/RStudio
source("R_scripts/istat_ricerca_sviluppo.R")
```

**Cosa fa:**
- Download dati ISTAT (con fallback a dataset realistico)
- Analisi esplorativa completa
- Creazione di tutti i grafici
- Analisi di serie temporali avanzate
- Export completo di risultati

### Opzione 2: Script Veloce

```r
# Per analisi rapida
source("R_scripts/download_rapido.R")
```

**Cosa fa:**
- Download veloce dei dati
- Analisi base e statistiche essenziali
- Grafico principale della serie storica
- Export essenziale

## 📋 Requisiti

### Pacchetti R Necessari

```r
# Pacchetti principali
install.packages(c(
  "tidyverse",    # Data wrangling e visualizzazione
  "ggplot2",      # Plotting avanzato
  "istat",        # Accesso API ISTAT
  "rsdmx",        # Alternative per accesso dati SDMX
  "dplyr",        # Manipolazione dati
  "readr",        # Lettura/scrittura dati
  "lubridate",    # Gestione date
  "skimr",        # Statistiche descrittive
  "janitor",      # Pulizia dati
  "plotly",       # Grafici interattivi
  "scales",       # Formati numerici
  "corrplot",     # Matrici di correlazione
  "tseries",      # Analisi serie temporali
  "forecast"      # Previsioni serie temporali
))
```

### Dipendenze di Sistema

- **R** (versione 4.0+)
- **RStudio** (raccomandato per sviluppo)

## 📊 Tipi di Output

### Dataset
- `data/spesa_rd_italia_pulita.csv` - Dataset pulito e standardizzato

### Grafici
- `serie_storica_principale.png/pdf` - Grafico principale della serie
- `variazioni_annuali.png` - Barplot delle variazioni anno su anno
- `distribuzione_spesa_rd.png` - Boxplot e distribuzione valori
- `confronto_europa.png` - Confronto Italia vs Media UE
- `decomposizione_serie.png` - Decomposizione trend/seasonal
- `previsioni_serie.png` - Previsioni future (5 anni)

### Statistiche
- `output/statistiche_riassuntive.csv` - Statistiche complete
- `output/log_analisi.txt` - Log completo dell'analisi

### Report
- `output/report_analisi_rd.html` - Report finale in HTML

## 🔧 Personalizzazione

### Modificare il Periodo Analizzato

Nel file `istat_ricerca_sviluppo.R`, modifica questi parametri:

```r
# Linea ~120: Parametri di esempio (da adattare)
params <- list(
  "startPeriod" = "1990",  # Cambia anno inizio
  "endPeriod" = "2023",    # Cambia anno fine
  "detail" = "full"
)
```

### Aggiungere Altri Paesi

Cerca nel codice la sezione "# CONFRONTO CON MEDIA EUROPEA" e modifica:

```r
eu_average <- data.frame(
  anno = 2000:2023,
  valore = rep(1.95, 24),  # Valore medio UE
  paese = "Media UE"
)
```

### Personalizzare i Grafici

I grafici possono essere personalizzati modificando le sezioni `create_visualizations()`:

```r
# Esempio: cambiare colori
scale_color_manual(values = c("Italia" = "#2E86AB", "Media UE" = "#F39C12"))

# Esempio: modificare temi
theme_minimal() +
theme(plot.title = element_text(size = 16, face = "bold"))
```

## 📈 Metriche Calcolate

Gli script calcolano automaticamente:

### Statistiche Descrittive
- **Valori minimo, massimo, medio, mediano**
- **Deviazione standard e coefficiente di variazione**
- **Completezza dati e periodi coperti**

### Analisi Trend
- **Tendenza generale** (crescente/decrescente)
- **Coefficiente angolare** (variazione annua)
- **R² del trend lineare**
- **Variazione percentuale totale**

### Analisi Temporali Avanzate
- **Test ADF** per stazionarietà
- **Decomposizione STL** (trend, seasonal, residual)
- **Previsioni ARIMA** per i prossimi 5 anni
- **Media mobile** per smoothing

## 🐛 Risoluzione Problemi

### Errore "Pacchetto non trovato"

```r
# Installa pacchetti mancanti
install.packages("nome_pacchetto")
```

### Errore API ISTAT

Gli script hanno un fallback automatico su dati realistici di esempio, quindi funzionano anche se l'API è temporaneamente indisponibile.

### Grafici non vengono salvati

Controlla che le directory esistano:
```r
dir.create("output/plots", recursive = TRUE)
```

## 📝 Note per la Tesi

Questi script sono ottimizzati per l'uso in contesto accademico:

- **Codice ben documentato** con commenti esplicativi
- **Riproducibile** - gli stessi input producono gli stessi output
- **Flessibile** - facilmente adattabile per altri indicatori ISTAT
- **Output professionale** - grafici e report di qualità accademica

## 🔗 Riferimenti Utili

- [ISTAT API SDMX](http://sdmx.istat.it/SDMXWS/)
- [Documentazione rsdmx](https://cran.r-project.org/web/packages/rsdmx/vignettes/rsdmx.html)
- [Tidyverse](https://www.tidyverse.org/)
- [ggplot2](https://ggplot2.tidyverse.org/)

## 📞 Supporto

Per problemi o domande sugli script:
1. Controlla i log nella cartella `output/`
2. Verifica che tutti i pacchetti siano installati
3. Assicurati di avere una connessione internet attiva per il download dati

---

**Buona analisi! 🚀**
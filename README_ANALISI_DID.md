# Analisi Difference-in-Differences: Impatto Conflitto Russia-Ucraina sul Settore Agroalimentare Italiano

## 📋 Descrizione

Questo script R implementa un'analisi **Difference-in-Differences (DiD)** completa per stimare l'effetto causale del conflitto russo-ucraino (iniziato il 24 febbraio 2022) su:

- **Salari** (costo del lavoro)
- **Occupazione** (numero di dipendenti)
- **Produttività** (Valore Aggiunto / Dipendenti)

delle imprese agroalimentari italiane utilizzando dati dal database AIDA (2017-2024).

## 🎯 Obiettivi dell'Analisi

### Analisi 1: Agroalimentare vs Altri Settori Manifatturieri
- **Treatment Group**: ATECO 10 (Alimentare) + ATECO 11 (Bevande)
- **Control Group**: ATECO 13-18, 22, 25 (Altri settori manifatturieri)
- **Ipotesi**: Il settore agroalimentare è stato più colpito dal conflitto a causa della dipendenza da materie prime ucraine/russe

### Analisi 2: Alimentare vs Bevande
- **Treatment Group**: ATECO 10 (Alimentare)
- **Control Group**: ATECO 11 (Bevande)
- **Ipotesi**: Il settore alimentare è stato più colpito rispetto alle bevande

## 📦 Requisiti

### Librerie R Necessarie

```r
install.packages(c(
  "tidyverse",    # Manipolazione dati e grafici
  "readxl",       # Lettura file Excel
  "lubridate",    # Gestione date
  "broom",        # Risultati modelli
  "stargazer",    # Tabelle output
  "ggplot2",      # Grafici
  "scales",       # Formattazione
  "fixest",       # Regressioni efficienti con FE
  "modelsummary", # Tabelle moderne
  "kableExtra",   # Formattazione tabelle
  "haven",        # Import/export formati statistici
  "janitor"       # Pulizia nomi variabili
))
```

Lo script installa automaticamente i pacchetti mancanti.

## 📁 Struttura Dati Richiesta

Il file Excel AIDA deve contenere le seguenti variabili (i nomi possono essere adattati nello script):

| Variabile | Descrizione | Tipo |
|-----------|-------------|------|
| `anno` | Anno di riferimento (2017-2024) | Numerico |
| `id_azienda` | Identificativo univoco azienda | Carattere/Numerico |
| `ateco_2` | Codice ATECO a 2 cifre | Numerico |
| `costo_lavoro` | Costo totale del lavoro (€) | Numerico |
| `dipendenti` | Numero di dipendenti (end of year) | Numerico |
| `valore_aggiunto` | Valore aggiunto (€) | Numerico |

### Esempio di Struttura Dati

| anno | id_azienda | ateco_2 | costo_lavoro | dipendenti | valore_aggiunto |
|------|------------|---------|--------------|------------|-----------------|
| 2017 | AZIENDA001 | 10 | 500000 | 50 | 1200000 |
| 2018 | AZIENDA001 | 10 | 520000 | 52 | 1250000 |
| 2019 | AZIENDA001 | 10 | 540000 | 53 | 1300000 |
| ... | ... | ... | ... | ... | ... |

## 🚀 Utilizzo

### 1. Preparare i Dati

Assicurarsi che il file Excel AIDA sia nel formato corretto e contenga tutte le variabili richieste.

### 2. Caricare lo Script

```r
# Impostare la directory di lavoro
setwd("/percorso/della/tua/cartella")

# Caricare lo script
source("did_analisi_russia_ucraina_agroalimentare.R")
```

### 3. Eseguire l'Analisi Completa

```r
# Eseguire l'analisi completa
risultati <- esegui_analisi_completa(
  file_path = "dati/database_aida_2017_2024.xlsx",
  sheet_name = "Dati"  # Opzionale, se il file ha più fogli
)
```

### 4. Accedere ai Risultati

```r
# Visualizzare summary di un modello specifico
summary(risultati$analisi_1$modelli_fe$log_costo_lavoro)

# Accedere ai dati preparati
df <- risultati$dati

# Visualizzare coefficienti DiD
coefficients(risultati$analisi_1$modelli_base$log_costo_lavoro)
```

## 📊 Output Generati

Dopo l'esecuzione, lo script crea automaticamente:

### 📁 `output/dati_preparati/`
- `dataset_did_preparato.rds`: Dataset preparato in formato R
- `dataset_did_preparato.csv`: Dataset preparato in formato CSV

### 📁 `output/tabelle/`
- `analisi1_did_base.html`: Risultati DiD Analisi 1 (modelli base)
- `analisi1_did_fixed_effects.html`: Risultati DiD Analisi 1 (con FE)
- `analisi2_did_base.html`: Risultati DiD Analisi 2 (modelli base)
- `analisi2_did_fixed_effects.html`: Risultati DiD Analisi 2 (con FE)

### 📁 `output/grafici/`
- `analisi1_parallel_trends_*.png`: Grafici parallel trends per Analisi 1
- `analisi1_event_study_*.png`: Grafici event study per Analisi 1
- `analisi2_parallel_trends_*.png`: Grafici parallel trends per Analisi 2
- `analisi2_event_study_*.png`: Grafici event study per Analisi 2

## 📈 Interpretazione dei Risultati

### Coefficiente DiD (Treatment × Post)

Il coefficiente chiave è **`Treatment × Post`**, che rappresenta l'**effetto causale stimato (ATT)**.

**Interpretazione** (usando log come variabile dipendente):

- **Coeff = 0.05** → Il trattamento ha causato un **+5%** di incremento nella variabile dipendente
- **Coeff = -0.08** → Il trattamento ha causato un **-8%** di riduzione nella variabile dipendente
- **p-value < 0.05** → L'effetto è statisticamente significativo

### Esempio di Lettura Tabella

```
Coefficiente Treatment × Post = -0.067***
Standard Error = (0.018)
R² = 0.652
N = 15,432
```

**Interpretazione**: Il conflitto russo-ucraino ha causato una riduzione del **6.7%** nel costo del lavoro delle imprese agroalimentari rispetto agli altri settori manifatturieri. L'effetto è statisticamente significativo (p < 0.01).

## ✅ Assunzioni DiD e Validazione

### 1. Parallel Trends Assumption

**L'assunzione critica**: Treatment e control devono avere trend paralleli **prima** del trattamento.

**Verifica**: Controllare i grafici `parallel_trends_*.png`:
- ✅ Le linee sono parallele prima del 2022 → Assunzione soddisfatta
- ❌ Le linee divergono prima del 2022 → Assunzione violata (risultati non validi)

### 2. No Anticipazione

Le imprese non devono aver cambiato comportamento prima del 24 febbraio 2022.

**Verifica**: Analizzare i grafici event study:
- ✅ Coefficienti pre-trattamento vicini a zero → No anticipazione
- ❌ Coefficienti pre-trattamento significativi → Possibile anticipazione

### 3. Composizione Stabile

Idealmente, le stesse imprese dovrebbero essere presenti in tutti gli anni (panel bilanciato).

## 🔧 Personalizzazione

### Modificare i Nomi delle Variabili

Se il file AIDA ha nomi diversi, modificare la funzione `prepara_dati_did()`:

```r
# Esempio: se il costo del lavoro si chiama "salari_totali"
df_prep <- df %>%
  rename(
    costo_lavoro = salari_totali,
    dipendenti = num_dipendenti
  )
```

### Aggiungere Variabili di Controllo

Modificare le funzioni `stima_did()` e `stima_did_fe()` per includere covariates:

```r
# Esempio: aggiungere dimensione azienda e regione
formula_str <- sprintf("%s ~ %s + post + %s + log_fatturato + regione", 
                       outcome_var, treatment_var, interaction_var)
```

### Cambiare Data Trattamento

Modificare il parametro all'inizio dello script:

```r
TRATTAMENTO_DATA <- as.Date("2022-02-24")  # Modificare se necessario
TRATTAMENTO_ANNO <- 2022
```

## 📚 Metodologia DiD

### Modello Base

$$Y_{it} = \beta_0 + \beta_1 \cdot Treatment_i + \beta_2 \cdot Post_t + \beta_3 \cdot (Treatment_i \times Post_t) + \varepsilon_{it}$$

Dove:
- $Y_{it}$: Variabile dipendente (salari, occupazione, produttività)
- $Treatment_i$: 1 se azienda è nel gruppo treatment, 0 altrimenti
- $Post_t$: 1 se anno ≥ 2022, 0 altrimenti
- $\beta_3$: **Effetto causale (ATT)** - differenza nelle differenze

### Modello con Fixed Effects

$$Y_{it} = \beta_3 \cdot (Treatment_i \times Post_t) + \alpha_i + \gamma_t + \varepsilon_{it}$$

Dove:
- $\alpha_i$: Fixed effects per azienda (controlla caratteristiche fisse non osservate)
- $\gamma_t$: Fixed effects per anno (controlla shock temporali comuni)

### Event Study

$$Y_{it} = \sum_{k \neq -1} \beta_k \cdot (Treatment_i \times 1[t - t_0 = k]) + \alpha_i + \gamma_t + \varepsilon_{it}$$

Dove:
- $k$: Anni relativi al trattamento ($k = -3, -2, 0, 1, 2, ...$)
- $k = -1$: Anno di riferimento (coefficiente normalizzato a 0)
- $\beta_k$: Effetto dinamico per ogni anno relativo

## 🔍 Analisi di Robustezza Consigliate

1. **Placebo Tests**: Utilizzare date false di trattamento (es. 2020) per verificare che non ci siano effetti spurii

2. **Esclusione di Outlier**: Rimuovere il top/bottom 1% delle variabili dipendenti

3. **Sub-campioni**: Analizzare separatamente per:
   - Dimensione azienda (piccole vs grandi)
   - Regione geografica (Nord vs Centro-Sud)
   - Export intensity (alta vs bassa)

4. **Propensity Score Matching**: Pre-processare i dati per migliorare comparabilità

5. **Standard Errors Alternativi**: Testare con bootstrap o wild cluster bootstrap

## 📝 Note Tecniche

### Trasformazione Logaritmica

Lo script utilizza **log(x + 1)** per trasformare le variabili:
- ✅ Permette interpretazione come variazioni percentuali
- ✅ Riduce l'influenza di outlier
- ✅ Gestisce valori zero (aggiungendo 1)

### Cluster Standard Errors

I modelli con fixed effects utilizzano cluster a livello di azienda per correggere per:
- Autocorrelazione seriale
- Eteroschedasticità

### Missing Values

Lo script rimuove automaticamente osservazioni con valori mancanti nelle variabili chiave. Per un approccio più sofisticato, considerare l'imputazione.

## 🆘 Troubleshooting

### Errore: "Variabile non trovata"

**Soluzione**: Verificare che i nomi delle variabili nel file Excel corrispondano a quelli nello script. Modificare la funzione `prepara_dati_did()` se necessario.

### Errore: "Insufficient observations"

**Soluzione**: Verificare che:
1. Il file Excel contenga dati per entrambi i periodi (pre e post 2022)
2. I codici ATECO siano corretti
3. Non ci siano troppi valori mancanti

### Warning: "Cannot compute event study"

**Soluzione**: L'event study richiede almeno 5 anni di dati. Se il dataset è più corto, questa analisi viene saltata automaticamente.

### Grafici non visualizzati

**Soluzione**: I grafici sono salvati automaticamente in `output/grafici/`. Per visualizzarli in RStudio, rimuovere il parametro `save_path` dalle funzioni.

## 📖 Riferimenti

- Angrist, J. D., & Pischke, J. S. (2009). *Mostly Harmless Econometrics*. Princeton University Press.
- Bertrand, M., Duflo, E., & Mullainathan, S. (2004). "How Much Should We Trust Differences-In-Differences Estimates?" *Quarterly Journal of Economics*, 119(1), 249-275.
- Callaway, B., & Sant'Anna, P. H. (2021). "Difference-in-Differences with multiple time periods." *Journal of Econometrics*, 225(2), 200-230.

## 👤 Autore

**Alessandro Di Toma**  
Master Thesis - Analisi dell'Impatto del Conflitto Russo-Ucraino

## 📄 Licenza

Questo script è fornito "as is" per scopi di ricerca accademica.

---

**Per domande o supporto**, contattare l'autore o consultare la documentazione delle librerie utilizzate.

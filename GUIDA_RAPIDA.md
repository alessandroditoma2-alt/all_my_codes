# 🚀 Guida Rapida - Analisi DiD Conflitto Russia-Ucraina

## ⚡ Quick Start (5 minuti)

### 1️⃣ Installare R e RStudio

Se non hai R installato, scaricalo da:
- **R**: https://cran.r-project.org/
- **RStudio**: https://posit.co/download/rstudio-desktop/

### 2️⃣ Testare con Dati Simulati

```r
# Aprire RStudio e impostare la directory di lavoro
setwd("/percorso/del/progetto")

# Generare dati di esempio
source("genera_dati_esempio.R")

# Eseguire l'analisi completa
source("did_analisi_russia_ucraina_agroalimentare.R")

risultati <- esegui_analisi_completa(
  file_path = "dati/database_aida_simulato.xlsx"
)
```

**Output**: Troverai tabelle e grafici in `output/`

### 3️⃣ Utilizzare Dati Reali (AIDA)

```r
# Quando hai il database AIDA reale
risultati <- esegui_analisi_completa(
  file_path = "percorso/database_aida_reale.xlsx",
  sheet_name = "Dati"  # Se necessario
)
```

---

## 📊 Interpretare i Risultati

### Tabelle HTML (output/tabelle/)

Aprire i file `.html` nel browser. Cercare il coefficiente:

**`Treatment × Post`** ← Questo è l'effetto del conflitto!

**Esempio**:
```
Treatment × Post = -0.067***
                   (0.018)
```

**Interpretazione**: Il conflitto ha causato una riduzione del **6.7%** nella variabile dipendente per il settore agroalimentare rispetto agli altri settori.

- `***` = significativo al 1% (p < 0.01) ✅
- `**` = significativo al 5% (p < 0.05) ✅
- `*` = significativo al 10% (p < 0.1) ⚠️
- Nessuna stella = non significativo ❌

### Grafici Parallel Trends (output/grafici/)

**Cosa cercare**:
- ✅ **BUONO**: Le linee sono parallele prima del 2022
- ❌ **CATTIVO**: Le linee divergono prima del 2022 (assunzione violata!)

Se l'assunzione è violata, i risultati non sono validi.

### Grafici Event Study (output/grafici/)

**Cosa cercare**:
- ✅ **BUONO**: Coefficienti pre-trattamento vicini a zero
- ❌ **CATTIVO**: Coefficienti pre-trattamento significativi (possibile anticipazione)

---

## 🔧 Personalizzazione Rapida

### Cambiare Variabili

Modificare in `did_analisi_russia_ucraina_agroalimentare.R`:

```r
# Linea ~80: se le variabili hanno nomi diversi
variabili_richieste <- c("anno", "ateco_2", "costo_lavoro", 
                         "dipendenti", "valore_aggiunto", "id_azienda")
```

Sostituire con i nomi reali del tuo file Excel.

### Cambiare Settori ATECO

```r
# Linee 60-63
ATECO_TREATMENT_1 <- c(10, 11)           # Modifica qui
ATECO_CONTROL_1   <- c(13, 14, 15, ...)  # Modifica qui
```

### Cambiare Data Trattamento

```r
# Linea 57
TRATTAMENTO_DATA <- as.Date("2022-02-24")  # Cambia questa data
TRATTAMENTO_ANNO <- 2022                    # Cambia questo anno
```

---

## 📈 Checklist Analisi

Prima di considerare i risultati validi:

- [ ] ✅ I grafici parallel trends mostrano trend paralleli pre-2022
- [ ] ✅ Il coefficiente DiD è statisticamente significativo (p < 0.05)
- [ ] ✅ I dati includono almeno 3 anni pre-trattamento e 2 post-trattamento
- [ ] ✅ Nessun evento confondente importante nello stesso periodo
- [ ] ✅ I risultati sono coerenti tra modelli base e fixed effects
- [ ] ✅ Gli event study non mostrano effetti pre-trattamento

---

## 🆘 Problemi Comuni

### Errore: "Cannot find variable X"

**Soluzione**: Il nome della variabile nel file Excel è diverso. Aprire il file Excel e controllare i nomi esatti, poi modificare lo script.

### Grafici parallel trends non paralleli

**Soluzione**: L'assunzione DiD è violata. Considerare:
1. Matching pre-processing (Propensity Score)
2. Cambiare gruppo di controllo
3. Includere covariates di controllo
4. Utilizzare metodi alternativi (Synthetic Control)

### Coefficiente non significativo

**Possibili cause**:
1. L'effetto è realmente zero
2. Campione troppo piccolo (bassa potenza statistica)
3. Gruppo di controllo inadeguato
4. Troppa variabilità nei dati

---

## 📚 File del Progetto

| File | Descrizione |
|------|-------------|
| `did_analisi_russia_ucraina_agroalimentare.R` | **Script principale** - Esegui questo |
| `genera_dati_esempio.R` | Genera dati simulati per testare |
| `README_ANALISI_DID.md` | Documentazione completa |
| `GUIDA_RAPIDA.md` | Questa guida |

---

## 💡 Tips

1. **Testare prima con dati simulati** per familiarizzare con lo script
2. **Verificare sempre i grafici** prima di interpretare le tabelle
3. **Salvare i risultati** con nomi descrittivi per confronti futuri
4. **Documentare le scelte** metodologiche per la tesi

---

## 📞 Supporto

Per problemi tecnici:
1. Leggere `README_ANALISI_DID.md` (documentazione completa)
2. Controllare la sezione Troubleshooting nel README
3. Verificare che tutte le librerie siano installate correttamente

---

**Buon lavoro con la tesi! 🎓**

# 🚀 INIZIA QUI!

## Benvenuto nell'Analisi DiD - Conflitto Russia-Ucraina

Hai appena ricevuto un **progetto completo** per analizzare l'impatto del conflitto russo-ucraino sul settore agroalimentare italiano usando la metodologia **Difference-in-Differences (DiD)**.

---

## ⚡ Quick Start (3 passi)

### 1️⃣ Apri RStudio e imposta la directory

```r
setwd("/percorso/dove/hai/scaricato/il/progetto")
```

### 2️⃣ Verifica che tutto funzioni

```r
source("test_installazione.R")
```

Questo script:
- ✅ Controlla la versione di R
- ✅ Verifica le librerie necessarie
- ✅ Installa automaticamente quelle mancanti
- ✅ Testa che tutto funzioni

### 3️⃣ Prova con dati simulati

```r
# Genera dati di esempio (simula database AIDA)
source("genera_dati_esempio.R")

# Esegui l'analisi completa
source("did_analisi_russia_ucraina_agroalimentare.R")
risultati <- esegui_analisi_completa("dati/database_aida_simulato.xlsx")
```

**Fatto!** 🎉 Ora hai:
- 📊 Tabelle con risultati DiD in `output/tabelle/`
- 📈 Grafici parallel trends in `output/grafici/`
- 📁 Dati preparati in `output/dati_preparati/`

---

## 📚 Cosa Leggere Dopo?

### Se hai **5 minuti**:
→ Leggi **`GUIDA_RAPIDA.md`**

### Se hai **15 minuti**:
→ Leggi **`README.md`** (panoramica completa)

### Se vuoi approfondire:
→ Leggi **`README_ANALISI_DID.md`** (documentazione tecnica)

### Se sei perso:
→ Leggi **`INDEX.md`** (mappa del progetto)

---

## 🎯 Cosa Troverai in Questo Progetto

### 📝 Script R Pronti all'Uso

| Script | Cosa Fa |
|--------|---------|
| `did_analisi_russia_ucraina_agroalimentare.R` | ⭐ **PRINCIPALE** - Analisi DiD completa |
| `genera_dati_esempio.R` | Crea dati simulati per testare |
| `esempi_avanzati.R` | Analisi di robustezza e placebo tests |
| `workflow_completo_esempio.R` | Workflow end-to-end con esempi |
| `test_installazione.R` | Verifica ambiente R |

### 📖 Documentazione Completa

- **README.md** - Panoramica progetto
- **GUIDA_RAPIDA.md** - Quick start 5 minuti
- **README_ANALISI_DID.md** - Documentazione tecnica
- **COMANDI_RAPIDI.md** - Cheat sheet comandi
- **INDEX.md** - Navigazione progetto
- **CHANGELOG.md** - Storia modifiche

### 📊 Analisi Implementate

1. **Analisi 1**: Agroalimentare (ATECO 10+11) vs Altri Settori Manifatturieri
   - Outcome: Salari, Occupazione, Produttività
   - Metodo: DiD con Fixed Effects

2. **Analisi 2**: Alimentare (ATECO 10) vs Bevande (ATECO 11)
   - Outcome: Salari, Occupazione, Produttività
   - Metodo: DiD con Fixed Effects

3. **Robustezza**:
   - Placebo tests
   - Pre-trend formale
   - Rimozione outlier
   - Eterogeneità (dimensione, regione)
   - Event study (effetti dinamici)

---

## 🔧 Prossimi Passi

### Con Dati Simulati (per imparare):

```r
# 1. Testa l'ambiente
source("test_installazione.R")

# 2. Genera dati
source("genera_dati_esempio.R")

# 3. Esegui analisi
source("did_analisi_russia_ucraina_agroalimentare.R")
risultati <- esegui_analisi_completa("dati/database_aida_simulato.xlsx")

# 4. Guarda i risultati
summary(risultati$analisi_1$modelli_fe$log_costo_lavoro)

# 5. Esegui robustezza
source("esempi_avanzati.R")
esegui_analisi_robustezza_completa(risultati)
```

### Con Dati Reali AIDA:

```r
# 1. Prepara il file Excel con variabili:
#    - anno, id_azienda, ateco_2
#    - costo_lavoro, dipendenti, valore_aggiunto

# 2. Carica lo script
source("did_analisi_russia_ucraina_agroalimentare.R")

# 3. Esegui analisi
risultati <- esegui_analisi_completa(
  file_path = "path/to/database_aida.xlsx",
  sheet_name = "Dati"  # se necessario
)

# 4. Verifica parallel trends (CRITICO!)
# Apri i grafici in output/grafici/
# Le linee devono essere parallele prima del 2022

# 5. Se OK → Interpreta risultati
# Se NO → Cambia gruppo controllo

# 6. Export per tesi
source("esempi_avanzati.R")
export_per_tesi(modelli_lista, output_latex = "risultati_tesi.tex")
```

---

## ✅ Checklist Prima di Usare Dati Reali

Prima di analizzare i dati AIDA reali, assicurati:

- [ ] R versione ≥ 4.0 installato
- [ ] RStudio installato (consigliato)
- [ ] Tutte le librerie installate (esegui `test_installazione.R`)
- [ ] File Excel AIDA contiene le variabili richieste:
  - `anno` (2017-2024)
  - `id_azienda` (identificativo univoco)
  - `ateco_2` (codice ATECO a 2 cifre)
  - `costo_lavoro` (o nome simile)
  - `dipendenti` (o num_dipendenti)
  - `valore_aggiunto` (per calcolare produttività)
- [ ] Hai testato l'analisi con dati simulati
- [ ] Hai letto almeno `GUIDA_RAPIDA.md`

---

## 💡 Tips Importanti

1. **Verifica sempre i grafici parallel trends**
   - Se non sono paralleli pre-2022, i risultati NON sono validi
   - È l'assunzione critica del metodo DiD

2. **Interpreta il coefficiente `Treatment × Post`**
   - È l'effetto causale del conflitto
   - Con log: interpretazione percentuale
   - Es: -0.067 → -6.7% di riduzione

3. **Controlla la significatività**
   - `***` = p < 0.01 (altamente significativo)
   - `**` = p < 0.05 (significativo)
   - `*` = p < 0.10 (debolmente significativo)

4. **Esegui analisi di robustezza**
   - Placebo tests
   - Rimozione outlier
   - Eterogeneità per sotto-gruppi

5. **Documenta tutto**
   - Salva grafici e tabelle
   - Annota scelte metodologiche
   - Usa `workflow_completo_esempio.R` come guida

---

## 🆘 Se Qualcosa Non Funziona

### Errore: "Package not found"
```r
# Installa manualmente
install.packages("nome_pacchetto")

# Oppure ri-esegui test
source("test_installazione.R")
```

### Errore: "Variable not found"
```r
# I nomi delle variabili nel tuo Excel sono diversi
# Modifica la funzione prepara_dati_did() nello script principale
# Vedi README_ANALISI_DID.md sezione "Personalizzazione"
```

### Parallel trends non paralleli
```r
# L'assunzione DiD è violata!
# Opzioni:
# 1. Cambia gruppo di controllo
# 2. Aggiungi covariates di controllo
# 3. Usa metodi alternativi (Synthetic Control)
```

### Altro problema?
→ Leggi **`README_ANALISI_DID.md`** sezione "Troubleshooting"

---

## 📞 Struttura Supporto

```
Domanda rapida?
    → COMANDI_RAPIDI.md

Problema tecnico?
    → README_ANALISI_DID.md § Troubleshooting

Vuoi approfondire metodo?
    → README_ANALISI_DID.md § Metodologia

Serve esempio pratico?
    → workflow_completo_esempio.R

Sei completamente perso?
    → INDEX.md (mappa del progetto)
```

---

## 🎓 Per la Tua Tesi

Questo progetto ti fornisce tutto il necessario per:

1. ✅ Stimare effetti causali con metodo DiD robusto
2. ✅ Verificare assunzioni metodologiche (parallel trends)
3. ✅ Produrre grafici publication-ready (300dpi PNG)
4. ✅ Generare tabelle formattate (HTML + LaTeX)
5. ✅ Condurre analisi di robustezza complete
6. ✅ Documentare scelte metodologiche
7. ✅ Interpretare risultati correttamente

**Output pronti per:**
- 📝 Capitolo metodologia (documenti .md)
- 📊 Risultati (tabelle HTML/LaTeX)
- 📈 Grafici (PNG 300dpi)
- 💾 Dati processati (CSV/RDS)

---

## 🌟 Caratteristiche Uniche

- 🚀 **Completamente automatizzato**: Un comando fa tutto
- 📊 **Grafici professionali**: Publication-ready
- 🔍 **Validazione integrata**: Parallel trends automatici
- 💪 **Robustezza completa**: Placebo, pre-trend, outlier
- 📚 **Documentazione italiana**: Tutto in italiano
- 🧪 **Testing incluso**: Dataset simulato pronto
- 📝 **Export flessibile**: HTML, LaTeX, CSV, RDS
- 🎓 **Pronto per tesi**: Formattazione professionale

---

## 🎉 Inizia Ora!

```r
# Passo 1: Verifica ambiente
source("test_installazione.R")

# Passo 2: Test con dati simulati
source("workflow_completo_esempio.R")

# Passo 3: Usa i tuoi dati reali
source("did_analisi_russia_ucraina_agroalimentare.R")
risultati <- esegui_analisi_completa("tuo_file_aida.xlsx")
```

---

**Buona fortuna con la tua tesi! 🎓📊✨**

---

_Per domande o problemi, consulta la documentazione completa._  
_Tutti i file sono commentati in italiano con spiegazioni dettagliate._

_Autore: Alessandro Di Toma_  
_Progetto: Master Thesis - Impatto Conflitto Russia-Ucraina_  
_Data: 16 Gennaio 2024_

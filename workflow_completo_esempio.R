################################################################################
# WORKFLOW COMPLETO - ESEMPIO PRATICO
# Dalla generazione dati all'analisi finale e reporting
#
# Autore: Alessandro Di Toma
# Descrizione: Questo script mostra un flusso di lavoro completo dall'inizio 
#              alla fine per l'analisi DiD
################################################################################

# ==============================================================================
# PASSO 0: SETUP INIZIALE
# ==============================================================================

cat("\n")
cat("================================================================================\n")
cat("  WORKFLOW COMPLETO ANALISI DiD\n")
cat("  Impatto Conflitto Russia-Ucraina su Settore Agroalimentare\n")
cat("================================================================================\n\n")

# Imposta directory di lavoro (modificare secondo necessità)
# setwd("/percorso/del/progetto")

# Verifica che tutti gli script siano presenti
file_necessari <- c(
  "did_analisi_russia_ucraina_agroalimentare.R",
  "genera_dati_esempio.R",
  "esempi_avanzati.R"
)

cat("VERIFICA FILE:\n")
for (file in file_necessari) {
  if (file.exists(file)) {
    cat(sprintf("  ✓ %s\n", file))
  } else {
    cat(sprintf("  ✗ %s MANCANTE\n", file))
    stop(sprintf("File mancante: %s", file))
  }
}
cat("\n")


# ==============================================================================
# PASSO 1: GENERAZIONE DATI SIMULATI (Solo per test)
# ==============================================================================
# Saltare questo passo se si hanno già dati reali AIDA

cat("PASSO 1: Generazione dati simulati\n")
cat("--------------------------------------------------------------------------------\n")

source("genera_dati_esempio.R")

cat("\n✓ Dati simulati generati con successo!\n")
cat("  File: dati/database_aida_simulato.xlsx\n\n")

# Aspetta un po' per vedere l'output
Sys.sleep(2)


# ==============================================================================
# PASSO 2: CARICAMENTO SCRIPT PRINCIPALE E ANALISI BASE
# ==============================================================================

cat("\nPASSO 2: Analisi DiD principale\n")
cat("--------------------------------------------------------------------------------\n")

# Carica lo script principale
source("did_analisi_russia_ucraina_agroalimentare.R")

# Esegui l'analisi completa
risultati <- esegui_analisi_completa(
  file_path = "dati/database_aida_simulato.xlsx"
)

cat("\n✓ Analisi principale completata!\n\n")

# Aspetta per vedere i risultati
Sys.sleep(2)


# ==============================================================================
# PASSO 3: ESAME RISULTATI PRINCIPALI
# ==============================================================================

cat("\nPASSO 3: Esame risultati principali\n")
cat("================================================================================\n\n")

# --- ANALISI 1: Agroalimentare vs Altri Settori ---
cat("ANALISI 1 - Agroalimentare (10+11) vs Altri Manifatturieri\n")
cat("--------------------------------------------------------------------------------\n\n")

# Modello per Costo del Lavoro
cat("📊 RISULTATI: Log(Costo Lavoro)\n\n")
modello_salari <- risultati$analisi_1$modelli_fe$log_costo_lavoro
summary(modello_salari)

# Estrai e interpreta il coefficiente DiD
coef_did_salari <- coef(modello_salari)["treat_post_1"]
se_did_salari <- summary(modello_salari)$se["treat_post_1"]
pval_did_salari <- summary(modello_salari)$coeftable["treat_post_1", "Pr(>|t|)"]

cat("\n" )
cat("INTERPRETAZIONE:\n")
cat(sprintf("Il conflitto russo-ucraino ha causato una variazione del %.2f%%\n", 
            coef_did_salari * 100))
cat(sprintf("nel costo del lavoro delle imprese agroalimentari rispetto agli altri settori.\n"))
cat(sprintf("Errore standard: %.4f, p-value: %.4f\n", se_did_salari, pval_did_salari))

if (pval_did_salari < 0.01) {
  cat("*** Effetto altamente significativo (p < 0.01)\n")
} else if (pval_did_salari < 0.05) {
  cat("** Effetto significativo (p < 0.05)\n")
} else if (pval_did_salari < 0.10) {
  cat("* Effetto debolmente significativo (p < 0.10)\n")
} else {
  cat("Effetto non statisticamente significativo\n")
}

cat("\n\n")

# Modello per Occupazione
cat("📊 RISULTATI: Log(Dipendenti)\n\n")
modello_occupazione <- risultati$analisi_1$modelli_fe$log_dipendenti
summary(modello_occupazione)

coef_did_occ <- coef(modello_occupazione)["treat_post_1"]
cat("\n")
cat("INTERPRETAZIONE:\n")
cat(sprintf("Variazione occupazione: %.2f%%\n\n", coef_did_occ * 100))

# Modello per Produttività
cat("📊 RISULTATI: Log(Produttività)\n\n")
modello_prod <- risultati$analisi_1$modelli_fe$log_produttivita
summary(modello_prod)

coef_did_prod <- coef(modello_prod)["treat_post_1"]
cat("\n")
cat("INTERPRETAZIONE:\n")
cat(sprintf("Variazione produttività: %.2f%%\n\n", coef_did_prod * 100))


cat("\n\n")
cat("--- ANALISI 2: Alimentare vs Bevande ---\n")
cat("--------------------------------------------------------------------------------\n\n")

modello_salari_2 <- risultati$analisi_2$modelli_fe$log_costo_lavoro
summary(modello_salari_2)

coef_did_2 <- coef(modello_salari_2)["treat_post_2"]
cat("\n")
cat("INTERPRETAZIONE:\n")
cat(sprintf("Il settore alimentare (ATECO 10) ha subito una variazione del %.2f%%\n", 
            coef_did_2 * 100))
cat("nel costo del lavoro rispetto al settore bevande (ATECO 11).\n\n")


# ==============================================================================
# PASSO 4: VERIFICA ASSUNZIONI (Parallel Trends)
# ==============================================================================

cat("\n\nPASSO 4: Verifica assunzioni DiD\n")
cat("================================================================================\n\n")

cat("📈 Controlla i grafici parallel trends in:\n")
cat("   output/grafici/analisi1_parallel_trends_*.png\n")
cat("   output/grafici/analisi2_parallel_trends_*.png\n\n")

cat("✓ Le linee devono essere PARALLELE prima del 2022\n")
cat("✗ Se le linee divergono prima del 2022, l'assunzione DiD è violata!\n\n")

# Visualizza un grafico (se in ambiente interattivo)
if (interactive()) {
  cat("Visualizzo grafico parallel trends per Costo Lavoro...\n")
  p_trend <- grafico_parallel_trends(
    risultati$dati, 
    "log_costo_lavoro", 
    analisi_id = 1
  )
  print(p_trend)
}


# ==============================================================================
# PASSO 5: ANALISI DI ROBUSTEZZA
# ==============================================================================

cat("\n\nPASSO 5: Analisi di robustezza\n")
cat("================================================================================\n\n")

# Carica funzioni avanzate
source("esempi_avanzati.R")

# Test 1: Placebo con anno 2020
cat("TEST 1: Placebo test (anno 2020)\n")
cat("--------------------------------------------------------------------------------\n")
modello_placebo_2020 <- placebo_test(risultati$dati, "log_costo_lavoro", anno_placebo = 2020)

cat("\n\n")

# Test 2: Pre-trend formale
cat("TEST 2: Test formale pre-trend\n")
cat("--------------------------------------------------------------------------------\n")
modello_pretrend <- test_pre_trend(risultati$dati, "log_costo_lavoro")

cat("\n\n")

# Test 3: Analisi senza outlier
cat("TEST 3: Analisi senza outlier\n")
cat("--------------------------------------------------------------------------------\n")
modelli_outlier <- did_senza_outlier(risultati$dati, "log_costo_lavoro", percentile_trim = 0.01)

cat("\n\n")

# Test 4: Eterogeneità per dimensione (se disponibile)
if ("dimensione" %in% names(risultati$dati)) {
  cat("TEST 4: Eterogeneità per dimensione azienda\n")
  cat("--------------------------------------------------------------------------------\n")
  
  sub_dimensione <- analisi_subgruppo(
    risultati$dati, 
    "log_costo_lavoro", 
    "dimensione"
  )
  
  cat("\n")
  print(sub_dimensione$risultati)
  cat("\n\n")
}


# ==============================================================================
# PASSO 6: TABELLA RIEPILOGATIVA
# ==============================================================================

cat("\nPASSO 6: Creazione tabella riepilogativa di robustezza\n")
cat("================================================================================\n\n")

# Raccogli tutti i modelli per confronto
modelli_confronto <- list(
  "Base (FE)" = risultati$analisi_1$modelli_fe$log_costo_lavoro,
  "Base (OLS)" = risultati$analisi_1$modelli_base$log_costo_lavoro,
  "Senza Outlier" = modelli_outlier$no_outlier
)

# Crea tabella
tabella_rob <- tabella_robustezza(
  modelli_confronto,
  nomi_modelli = names(modelli_confronto),
  output_path = "output/tabelle/robustezza_completa.html"
)

print(tabella_rob)

cat("\n✓ Tabella di robustezza salvata in:\n")
cat("   output/tabelle/robustezza_completa.html\n\n")


# ==============================================================================
# PASSO 7: RIEPILOGO ESECUTIVO
# ==============================================================================

cat("\n\nPASSO 7: Riepilogo esecutivo\n")
cat("================================================================================\n\n")

# Crea un riepilogo testuale

riepilogo <- sprintf("
RIEPILOGO ESECUTIVO - ANALISI DiD
==================================

DOMANDA DI RICERCA:
Qual è stato l'impatto del conflitto russo-ucraino (dal 24 febbraio 2022) 
sul settore agroalimentare italiano in termini di salari, occupazione e produttività?

METODOLOGIA:
Difference-in-Differences con fixed effects (azienda + anno)

RISULTATI PRINCIPALI:
-------------------

ANALISI 1 - Agroalimentare (ATECO 10+11) vs Altri Settori Manifatturieri:

  • Costo del Lavoro:     %+.2f%% %s
  • Occupazione:          %+.2f%% %s
  • Produttività:         %+.2f%% %s

ANALISI 2 - Alimentare (ATECO 10) vs Bevande (ATECO 11):

  • Costo del Lavoro:     %+.2f%% %s

VALIDITÀ RISULTATI:
------------------
  
  ✓ Parallel trends:      Verificare grafici in output/grafici/
  ✓ Placebo test:         %s
  ✓ Test pre-trend:       %s
  ✓ Robustezza outlier:   %s

INTERPRETAZIONE:
---------------
Il settore agroalimentare %s un effetto %s dal conflitto russo-ucraino
rispetto agli altri settori manifatturieri. L'effetto è %s statisticamente.

RACCOMANDAZIONI:
---------------
1. Verificare visivamente i grafici parallel trends
2. Considerare analisi di eterogeneità (per dimensione, regione)
3. Approfondire i meccanismi causali (prezzi materie prime, export)
4. Analizzare la persistenza degli effetti nel tempo

OUTPUT DISPONIBILI:
------------------
  • Tabelle: output/tabelle/
  • Grafici: output/grafici/
  • Dati preparati: output/dati_preparati/

================================================================================
",
  coef_did_salari * 100,
  ifelse(pval_did_salari < 0.05, "***", ifelse(pval_did_salari < 0.10, "**", "")),
  
  coef_did_occ * 100,
  ifelse(summary(modello_occupazione)$coeftable["treat_post_1", "Pr(>|t|)"] < 0.05, "***", ""),
  
  coef_did_prod * 100,
  ifelse(summary(modello_prod)$coeftable["treat_post_1", "Pr(>|t|)"] < 0.05, "***", ""),
  
  coef_did_2 * 100,
  ifelse(summary(modello_salari_2)$coeftable["treat_post_2", "Pr(>|t|)"] < 0.05, "***", ""),
  
  ifelse(summary(modello_placebo_2020)$coeftable["treat_post_placebo", "Pr(>|t|)"] > 0.05, 
         "Superato", "Non superato"),
  ifelse(summary(modello_pretrend)$coeftable["treatment_1:anni_da_base", "Pr(>|t|)"] > 0.05,
         "Superato", "Non superato"),
  ifelse(abs(coef(modelli_outlier$completo)["treat_post_1"] - coef(modelli_outlier$no_outlier)["treat_post_1"]) < 0.01,
         "Confermato", "Variabile"),
  
  ifelse(abs(coef_did_salari) > 0.02, "ha subito", "non ha mostrato"),
  ifelse(coef_did_salari < 0, "negativo", "positivo"),
  ifelse(pval_did_salari < 0.05, "significativo", "non significativo")
)

cat(riepilogo)

# Salva il riepilogo in un file
writeLines(riepilogo, "output/riepilogo_esecutivo.txt")
cat("\n✓ Riepilogo salvato in: output/riepilogo_esecutivo.txt\n\n")


# ==============================================================================
# PASSO 8: EXPORT PER TESI
# ==============================================================================

cat("\nPASSO 8: Export tabelle per tesi (formato LaTeX)\n")
cat("================================================================================\n\n")

# Raccogli i modelli principali per le 3 variabili dipendenti
modelli_tesi <- list(
  risultati$analisi_1$modelli_fe$log_costo_lavoro,
  risultati$analisi_1$modelli_fe$log_dipendenti,
  risultati$analisi_1$modelli_fe$log_produttivita
)

# Export in formato LaTeX
tryCatch({
  stargazer::stargazer(
    modelli_tesi,
    type = "latex",
    title = "Effetto del Conflitto Russia-Ucraina sul Settore Agroalimentare Italiano",
    dep.var.labels = c("Log(Costo Lavoro)", "Log(Occupazione)", "Log(Produttività)"),
    covariate.labels = c("Treatment × Post (DiD)"),
    keep = "treat_post_1",
    omit.stat = c("f", "ser"),
    out = "output/tabelle/tabella_tesi_principale.tex",
    header = FALSE,
    notes = c("Note: Modelli con fixed effects per azienda e anno.",
              "Errori standard (clustered per azienda) tra parentesi.",
              "*** p<0.01, ** p<0.05, * p<0.1"),
    notes.append = FALSE
  )
  
  cat("✓ Tabella LaTeX salvata in:\n")
  cat("   output/tabelle/tabella_tesi_principale.tex\n\n")
  cat("  Puoi copiare il contenuto nel tuo documento LaTeX!\n\n")
}, error = function(e) {
  cat("⚠ Errore nell'export LaTeX:", e$message, "\n")
  cat("  Verifica che il pacchetto stargazer sia installato\n\n")
})


# ==============================================================================
# WORKFLOW COMPLETATO
# ==============================================================================

cat("\n")
cat("================================================================================\n")
cat("  ✅ WORKFLOW COMPLETATO CON SUCCESSO!\n")
cat("================================================================================\n\n")

cat("PROSSIMI PASSI PER LA TESI:\n")
cat("--------------------------\n\n")

cat("1. 📊 VERIFICA GRAFICI:\n")
cat("   • Apri i file PNG in output/grafici/\n")
cat("   • Controlla che i parallel trends siano soddisfatti\n")
cat("   • Esamina gli event study per effetti dinamici\n\n")

cat("2. 📋 ANALIZZA TABELLE:\n")
cat("   • Apri i file HTML in output/tabelle/\n")
cat("   • Interpreta i coefficienti DiD\n")
cat("   • Verifica la significatività statistica\n\n")

cat("3. ✍️ SCRIVI LA TESI:\n")
cat("   • Utilizza il riepilogo esecutivo come base\n")
cat("   • Incorpora i grafici nelle sezioni appropriate\n")
cat("   • Copia le tabelle LaTeX nel documento\n\n")

cat("4. 🔬 ANALISI AGGIUNTIVE (opzionali):\n")
cat("   • Esplora eterogeneità per regione/dimensione\n")
cat("   • Conduci ulteriori test di robustezza\n")
cat("   • Considera analisi di meccanismi causali\n\n")

cat("5. 🔄 CON DATI REALI:\n")
cat("   • Sostituisci il file simulato con database AIDA reale\n")
cat("   • Adatta i nomi delle variabili se necessario\n")
cat("   • Ri-esegui l'intero workflow\n\n")

cat("================================================================================\n")
cat("  FILE OUTPUT PRONTI PER LA TESI:\n")
cat("================================================================================\n\n")

# Lista tutti i file creati
cat("📁 TABELLE (output/tabelle/):\n")
files_tabelle <- list.files("output/tabelle/", full.names = FALSE)
for (f in files_tabelle) {
  cat(sprintf("   • %s\n", f))
}

cat("\n📁 GRAFICI (output/grafici/):\n")
files_grafici <- list.files("output/grafici/", full.names = FALSE)
for (f in files_grafici) {
  cat(sprintf("   • %s\n", f))
}

cat("\n📁 DATI (output/dati_preparati/):\n")
files_dati <- list.files("output/dati_preparati/", full.names = FALSE)
for (f in files_dati) {
  cat(sprintf("   • %s\n", f))
}

cat("\n📄 DOCUMENTI:\n")
cat("   • output/riepilogo_esecutivo.txt\n")

cat("\n\n")
cat("================================================================================\n")
cat("  BUON LAVORO CON LA TUA TESI! 🎓📊\n")
cat("================================================================================\n\n")

cat("Per domande o problemi:\n")
cat("  • Consulta README_ANALISI_DID.md (documentazione completa)\n")
cat("  • Consulta GUIDA_RAPIDA.md (guida quick start)\n")
cat("  • Utilizza esempi_avanzati.R per analisi aggiuntive\n\n")

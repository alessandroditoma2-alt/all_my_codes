################################################################################
# ESEMPI AVANZATI E ANALISI DI ROBUSTEZZA
# Estensioni dell'analisi DiD principale
#
# Autore: Alessandro Di Toma
# Descrizione: Esempi di analisi complementari, test di robustezza, 
#              e personalizzazioni comuni
################################################################################

# Prerequisito: aver già eseguito l'analisi principale
# source("did_analisi_russia_ucraina_agroalimentare.R")
# risultati <- esegui_analisi_completa("dati/database_aida_simulato.xlsx")

library(tidyverse)
library(fixest)
library(modelsummary)
library(ggplot2)


# ==============================================================================
# 1. PLACEBO TEST: Data Falsa di Trattamento
# ==============================================================================
# Obiettivo: Verificare che non ci siano effetti spurii in periodi senza trattamento
# Metodo: Utilizzare una data di trattamento falsa (es. 2020 invece di 2022)

placebo_test <- function(df, outcome_var, anno_placebo = 2020) {
  
  cat(sprintf("\n=== PLACEBO TEST: Anno placebo = %d ===\n", anno_placebo))
  
  # Crea variabili placebo
  df_placebo <- df %>%
    filter(incluso_analisi_1 == 1, anno < 2022) %>%  # Solo periodo pre-conflitto
    mutate(
      post_placebo = if_else(anno >= anno_placebo, 1, 0),
      treat_post_placebo = treatment_1 * post_placebo
    )
  
  # Stima modello placebo
  formula_placebo <- sprintf("%s ~ treatment_1 + post_placebo + treat_post_placebo", 
                             outcome_var)
  
  modello_placebo <- feols(as.formula(formula_placebo), 
                           data = df_placebo, 
                           cluster = "id_azienda")
  
  # Verifica risultato
  coef_placebo <- coef(modello_placebo)["treat_post_placebo"]
  pval_placebo <- summary(modello_placebo)$coeftable["treat_post_placebo", "Pr(>|t|)"]
  
  cat(sprintf("\nCoefficienti placebo DiD: %.4f (p-value: %.4f)\n", 
              coef_placebo, pval_placebo))
  
  if (pval_placebo > 0.05) {
    cat("✓ PLACEBO TEST SUPERATO: Nessun effetto significativo nel periodo placebo\n")
  } else {
    cat("⚠ PLACEBO TEST FALLITO: Effetto significativo nel periodo placebo (possibile pre-trend)\n")
  }
  
  return(modello_placebo)
}

# Esempio di utilizzo:
# placebo_2020 <- placebo_test(risultati$dati, "log_costo_lavoro", anno_placebo = 2020)


# ==============================================================================
# 2. ANALISI PER SUB-GRUPPI: Eterogeneità degli Effetti
# ==============================================================================
# Obiettivo: Verificare se l'effetto del conflitto è diverso per dimensione, regione, ecc.

analisi_subgruppo <- function(df, outcome_var, gruppo_var) {
  
  cat(sprintf("\n=== ANALISI SUB-GRUPPI: %s ===\n", gruppo_var))
  
  # Filtra per analisi 1
  df_sub <- df %>% filter(incluso_analisi_1 == 1)
  
  # Ottieni categorie del gruppo
  categorie <- unique(df_sub[[gruppo_var]])
  
  modelli_sub <- list()
  risultati_sub <- tibble()
  
  for (cat in categorie) {
    
    cat(sprintf("\nStima per %s = %s\n", gruppo_var, cat))
    
    # Filtra per categoria
    df_cat <- df_sub %>% filter(!!sym(gruppo_var) == cat)
    
    # Stima DiD
    formula_did <- sprintf("%s ~ treatment_1 + post + treat_post_1", outcome_var)
    
    modello <- feols(as.formula(formula_did), 
                     data = df_cat, 
                     cluster = "id_azienda")
    
    modelli_sub[[as.character(cat)]] <- modello
    
    # Estrai coefficiente DiD
    coef_did <- coef(modello)["treat_post_1"]
    se_did <- summary(modello)$se["treat_post_1"]
    pval_did <- summary(modello)$coeftable["treat_post_1", "Pr(>|t|)"]
    n_obs <- nobs(modello)
    
    risultati_sub <- bind_rows(
      risultati_sub,
      tibble(
        gruppo = gruppo_var,
        categoria = as.character(cat),
        coefficiente = coef_did,
        std_error = se_did,
        p_value = pval_did,
        n = n_obs
      )
    )
    
    cat(sprintf("  Coefficiente DiD: %.4f (SE: %.4f, p: %.4f, N: %d)\n", 
                coef_did, se_did, pval_did, n_obs))
  }
  
  # Crea grafico coefficienti per sub-gruppi
  p <- ggplot(risultati_sub, aes(x = categoria, y = coefficiente)) +
    geom_point(size = 4, color = "#E74C3C") +
    geom_errorbar(aes(ymin = coefficiente - 1.96*std_error, 
                      ymax = coefficiente + 1.96*std_error),
                  width = 0.2, size = 1, color = "#E74C3C") +
    geom_hline(yintercept = 0, linetype = "dashed") +
    labs(
      title = sprintf("Effetti DiD per %s", gruppo_var),
      subtitle = sprintf("Outcome: %s", outcome_var),
      x = gruppo_var,
      y = "Coefficiente DiD",
      caption = "Barre di errore: IC 95%"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  print(p)
  
  return(list(modelli = modelli_sub, risultati = risultati_sub, grafico = p))
}

# Esempio di utilizzo:
# sub_dimensione <- analisi_subgruppo(risultati$dati, "log_costo_lavoro", "dimensione")
# sub_regione <- analisi_subgruppo(risultati$dati, "log_costo_lavoro", "regione")


# ==============================================================================
# 3. MODELLI CON COVARIATES DI CONTROLLO
# ==============================================================================
# Obiettivo: Controllare per caratteristiche osservabili che potrebbero confondere

did_con_controlli <- function(df, outcome_var, controlli = c("log_fatturato", "dimensione")) {
  
  cat("\n=== DiD CON COVARIATES DI CONTROLLO ===\n")
  
  df_analisi <- df %>% filter(incluso_analisi_1 == 1)
  
  # Formula base (senza controlli)
  formula_base <- sprintf("%s ~ treat_post_1 | id_azienda + anno", outcome_var)
  
  # Formula con controlli
  controlli_str <- paste(controlli, collapse = " + ")
  formula_controlli <- sprintf("%s ~ treat_post_1 + %s | id_azienda + anno", 
                               outcome_var, controlli_str)
  
  # Stima modelli
  modello_base <- feols(as.formula(formula_base), 
                        data = df_analisi, 
                        cluster = "id_azienda")
  
  modello_controlli <- feols(as.formula(formula_controlli), 
                             data = df_analisi, 
                             cluster = "id_azienda")
  
  # Confronta risultati
  cat("\nConfonto coefficienti DiD:\n")
  cat(sprintf("  Senza controlli: %.4f\n", coef(modello_base)["treat_post_1"]))
  cat(sprintf("  Con controlli:   %.4f\n", coef(modello_controlli)["treat_post_1"]))
  
  # Tabella comparativa
  modelsummary(
    list("Base" = modello_base, "Con Controlli" = modello_controlli),
    stars = TRUE,
    gof_map = c("nobs", "r.squared")
  )
  
  return(list(base = modello_base, controlli = modello_controlli))
}

# Esempio di utilizzo (se hai variabili di controllo nel dataset):
# modelli_controlli <- did_con_controlli(risultati$dati, "log_costo_lavoro", 
#                                         controlli = c("dimensione", "regione"))


# ==============================================================================
# 4. RIMOZIONE OUTLIER
# ==============================================================================
# Obiettivo: Verificare che i risultati non siano guidati da valori estremi

did_senza_outlier <- function(df, outcome_var, percentile_trim = 0.01) {
  
  cat(sprintf("\n=== DiD SENZA OUTLIER (trim %.1f%%) ===\n", percentile_trim * 100))
  
  df_analisi <- df %>% filter(incluso_analisi_1 == 1)
  
  # Calcola percentili
  q_low <- quantile(df_analisi[[outcome_var]], percentile_trim, na.rm = TRUE)
  q_high <- quantile(df_analisi[[outcome_var]], 1 - percentile_trim, na.rm = TRUE)
  
  cat(sprintf("Rimozione valori < %.2f e > %.2f\n", q_low, q_high))
  
  # Rimuovi outlier
  df_no_outlier <- df_analisi %>%
    filter(!!sym(outcome_var) >= q_low & !!sym(outcome_var) <= q_high)
  
  n_rimossi <- nrow(df_analisi) - nrow(df_no_outlier)
  cat(sprintf("Osservazioni rimosse: %d (%.1f%%)\n", 
              n_rimossi, n_rimossi / nrow(df_analisi) * 100))
  
  # Stima modello senza outlier
  formula_did <- sprintf("%s ~ treat_post_1 | id_azienda + anno", outcome_var)
  
  modello_completo <- feols(as.formula(formula_did), 
                            data = df_analisi, 
                            cluster = "id_azienda")
  
  modello_no_outlier <- feols(as.formula(formula_did), 
                              data = df_no_outlier, 
                              cluster = "id_azienda")
  
  # Confronta
  cat("\nConfonto coefficienti:\n")
  cat(sprintf("  Con outlier:    %.4f\n", coef(modello_completo)["treat_post_1"]))
  cat(sprintf("  Senza outlier:  %.4f\n", coef(modello_no_outlier)["treat_post_1"]))
  
  return(list(completo = modello_completo, no_outlier = modello_no_outlier))
}

# Esempio di utilizzo:
# modelli_outlier <- did_senza_outlier(risultati$dati, "log_costo_lavoro", percentile_trim = 0.01)


# ==============================================================================
# 5. TEST PRE-TREND FORMALE (Regressione)
# ==============================================================================
# Obiettivo: Test statistico formale dell'assunzione parallel trends

test_pre_trend <- function(df, outcome_var) {
  
  cat("\n=== TEST FORMALE PRE-TREND ===\n")
  
  # Filtra solo periodo pre-trattamento
  df_pre <- df %>% 
    filter(incluso_analisi_1 == 1, anno < 2022) %>%
    mutate(anni_da_base = anno - min(anno))
  
  # Regressione: Y = α + β1*Treatment + β2*Trend + β3*(Treatment × Trend) + ε
  # Se β3 ≠ 0, c'è un pre-trend differenziale (problema!)
  
  formula_pretrend <- sprintf("%s ~ treatment_1 + anni_da_base + treatment_1:anni_da_base", 
                              outcome_var)
  
  modello_pretrend <- feols(as.formula(formula_pretrend), 
                            data = df_pre, 
                            cluster = "id_azienda")
  
  # Estrai coefficiente interazione
  coef_interaction <- coef(modello_pretrend)["treatment_1:anni_da_base"]
  pval_interaction <- summary(modello_pretrend)$coeftable["treatment_1:anni_da_base", "Pr(>|t|)"]
  
  cat("\nRisultati test pre-trend:\n")
  cat(sprintf("  Coefficiente Treatment × Trend: %.4f (p-value: %.4f)\n", 
              coef_interaction, pval_interaction))
  
  if (pval_interaction > 0.05) {
    cat("✓ TEST SUPERATO: Nessun pre-trend differenziale significativo\n")
  } else {
    cat("⚠ TEST FALLITO: Pre-trend differenziale significativo (violazione parallel trends)\n")
  }
  
  return(modello_pretrend)
}

# Esempio di utilizzo:
# test_pretrend <- test_pre_trend(risultati$dati, "log_costo_lavoro")


# ==============================================================================
# 6. TABELLA RIEPILOGATIVA DI ROBUSTEZZA
# ==============================================================================
# Obiettivo: Confrontare tutti i modelli di robustezza in una singola tabella

tabella_robustezza <- function(modelli_lista, nomi_modelli, output_path = NULL) {
  
  cat("\n=== TABELLA RIEPILOGATIVA ROBUSTEZZA ===\n")
  
  # Crea tabella con modelsummary
  tabella <- modelsummary(
    modelli_lista,
    stars = TRUE,
    coef_rename = c("treat_post_1" = "Treatment × Post (DiD)"),
    gof_map = c("nobs", "r.squared"),
    title = "Analisi di Robustezza - Confronto Modelli",
    notes = "*** p<0.01, ** p<0.05, * p<0.1"
  )
  
  # Salva se richiesto
  if (!is.null(output_path)) {
    tabella %>%
      kable_styling(bootstrap_options = c("striped", "hover")) %>%
      save_kable(file = output_path)
    cat(sprintf("✓ Tabella salvata: %s\n", output_path))
  }
  
  return(tabella)
}

# Esempio di utilizzo:
# modelli_rob <- list(
#   "Base" = risultati$analisi_1$modelli_fe$log_costo_lavoro,
#   "Placebo 2020" = placebo_2020,
#   "Senza Outlier" = modelli_outlier$no_outlier
# )
# tabella_robustezza(modelli_rob, output_path = "output/tabelle/robustezza.html")


# ==============================================================================
# 7. ANALISI TEMPORALE DETTAGLIATA (Trimestrale/Mensile)
# ==============================================================================
# Se i dati sono disponibili a frequenza più alta (trimestrale/mensile)

did_alta_frequenza <- function(df, outcome_var, time_var = "trimestre") {
  
  cat(sprintf("\n=== DiD CON DATI AD ALTA FREQUENZA (%s) ===\n", time_var))
  
  # Identifica il periodo di trattamento
  # Es: Se time_var è "anno_trimestre" (formato: "2022_Q1")
  
  df_hf <- df %>%
    filter(incluso_analisi_1 == 1) %>%
    mutate(
      post_hf = if_else(!!sym(time_var) >= "2022_Q1", 1, 0),
      treat_post_hf = treatment_1 * post_hf
    )
  
  # Stima DiD con fixed effects per periodo
  formula_hf <- sprintf("%s ~ treat_post_hf | id_azienda + %s", outcome_var, time_var)
  
  modello_hf <- feols(as.formula(formula_hf), 
                      data = df_hf, 
                      cluster = "id_azienda")
  
  cat("\nRisultati DiD alta frequenza:\n")
  print(summary(modello_hf))
  
  return(modello_hf)
}


# ==============================================================================
# 8. EXPORT RISULTATI PER TESI (LaTeX)
# ==============================================================================

export_per_tesi <- function(modelli_lista, nomi_modelli, output_latex) {
  
  cat("\n=== EXPORT TABELLE PER TESI (LaTeX) ===\n")
  
  # Crea tabella LaTeX
  stargazer(
    modelli_lista,
    type = "latex",
    title = "Risultati Analisi Difference-in-Differences",
    dep.var.labels = c("Log(Salari)", "Log(Occupazione)", "Log(Produttività)"),
    covariate.labels = c("Treatment × Post", "Treatment", "Post"),
    omit.stat = c("f", "ser"),
    out = output_latex,
    header = FALSE,
    font.size = "small",
    column.sep.width = "1pt"
  )
  
  cat(sprintf("✓ Tabella LaTeX salvata: %s\n", output_latex))
  cat("  Copia il contenuto nel tuo documento LaTeX\n")
}

# Esempio di utilizzo:
# export_per_tesi(
#   modelli_lista = list(
#     risultati$analisi_1$modelli_fe$log_costo_lavoro,
#     risultati$analisi_1$modelli_fe$log_dipendenti,
#     risultati$analisi_1$modelli_fe$log_produttivita
#   ),
#   output_latex = "output/tabelle/risultati_tesi.tex"
# )


# ==============================================================================
# 9. DASHBOARD INTERATTIVO (Opzionale, richiede shiny)
# ==============================================================================

# Crea un dashboard Shiny interattivo per esplorare i risultati
# Decommentare se si vuole utilizzare

# library(shiny)
# 
# dashboard_did <- function(risultati) {
#   
#   ui <- fluidPage(
#     titlePanel("Dashboard Analisi DiD - Conflitto Russia-Ucraina"),
#     
#     sidebarLayout(
#       sidebarPanel(
#         selectInput("analisi", "Scegli Analisi:",
#                     choices = c("Analisi 1", "Analisi 2")),
#         selectInput("outcome", "Variabile Dipendente:",
#                     choices = c("Costo Lavoro", "Occupazione", "Produttività")),
#         selectInput("modello", "Tipo Modello:",
#                     choices = c("Base OLS", "Fixed Effects"))
#       ),
#       
#       mainPanel(
#         h3("Risultati Modello"),
#         verbatimTextOutput("summary"),
#         h3("Grafico Parallel Trends"),
#         plotOutput("parallel_trends")
#       )
#     )
#   )
#   
#   server <- function(input, output) {
#     # Implementazione reattiva qui...
#   }
#   
#   shinyApp(ui = ui, server = server)
# }


# ==============================================================================
# ESECUZIONE COMPLETA DI TUTTI I TEST DI ROBUSTEZZA
# ==============================================================================

esegui_analisi_robustezza_completa <- function(risultati, outcome_var = "log_costo_lavoro") {
  
  cat("\n")
  cat("================================================================================\n")
  cat("  ANALISI DI ROBUSTEZZA COMPLETA\n")
  cat("================================================================================\n")
  
  df <- risultati$dati
  
  # 1. Placebo test
  cat("\n1. PLACEBO TEST\n")
  modello_placebo <- placebo_test(df, outcome_var, anno_placebo = 2020)
  
  # 2. Test pre-trend formale
  cat("\n2. TEST PRE-TREND FORMALE\n")
  modello_pretrend <- test_pre_trend(df, outcome_var)
  
  # 3. Analisi senza outlier
  cat("\n3. ANALISI SENZA OUTLIER\n")
  modelli_outlier <- did_senza_outlier(df, outcome_var, percentile_trim = 0.01)
  
  # 4. Analisi per sub-gruppi (se disponibili)
  if ("dimensione" %in% names(df)) {
    cat("\n4. ANALISI PER DIMENSIONE AZIENDA\n")
    sub_dimensione <- analisi_subgruppo(df, outcome_var, "dimensione")
  }
  
  if ("regione" %in% names(df)) {
    cat("\n5. ANALISI PER REGIONE\n")
    sub_regione <- analisi_subgruppo(df, outcome_var, "regione")
  }
  
  # Riepilogo
  cat("\n")
  cat("================================================================================\n")
  cat("  RIEPILOGO ROBUSTEZZA\n")
  cat("================================================================================\n\n")
  cat("Tutti i test di robustezza sono stati eseguiti.\n")
  cat("Controlla i risultati sopra per verificare la validità dell'analisi principale.\n\n")
  
  cat("✓ Analisi di robustezza completata!\n\n")
}

# Esempio di utilizzo:
# esegui_analisi_robustezza_completa(risultati, outcome_var = "log_costo_lavoro")


################################################################################
# FINE ESEMPI AVANZATI
################################################################################

cat("\n✓ Script esempi avanzati caricato con successo!\n\n")
cat("Funzioni disponibili:\n")
cat("  • placebo_test() - Test con data falsa di trattamento\n")
cat("  • analisi_subgruppo() - Eterogeneità per dimensione/regione\n")
cat("  • did_con_controlli() - Modelli con covariates\n")
cat("  • did_senza_outlier() - Rimuovi valori estremi\n")
cat("  • test_pre_trend() - Test formale parallel trends\n")
cat("  • tabella_robustezza() - Tabella comparativa modelli\n")
cat("  • export_per_tesi() - Export LaTeX per tesi\n")
cat("  • esegui_analisi_robustezza_completa() - Esegui tutto\n\n")

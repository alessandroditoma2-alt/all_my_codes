################################################################################
# ANALISI DIFFERENCE-IN-DIFFERENCES (DiD)
# Impatto del Conflitto Russo-Ucraino sul Settore Agroalimentare Italiano
# 
# Autore: Alessandro Di Toma
# Data: 2024
# Fonte dati: Database AIDA (2017-2024)
#
# Obiettivo: Stimare l'effetto causale del conflitto russo-ucraino 
#            (iniziato il 24 febbraio 2022) su:
#            - Salari (costo del lavoro)
#            - Occupazione (numero dipendenti)
#            - Produttività (Valore Aggiunto / Dipendenti)
#
# Metodologia: Difference-in-Differences con:
#              1) Treatment: ATECO 10+11 (agroalimentare) vs Control: ATECO 13-18,22,25
#              2) Treatment: ATECO 10 (alimentare) vs Control: ATECO 11 (bevande)
################################################################################

# INSTALLAZIONE E CARICAMENTO LIBRERIE ========================================

# Lista delle librerie necessarie
pacchetti_necessari <- c(
  "tidyverse",      # Manipolazione dati e grafici
  "readxl",         # Importazione file Excel
  "lubridate",      # Gestione date
  "broom",          # Risultati modelli in formato tidy
  "stargazer",      # Tabelle regression output
  "ggplot2",        # Grafici avanzati
  "scales",         # Formattazione assi grafici
  "fixest",         # Regressioni con fixed effects (più efficiente di lm)
  "modelsummary",   # Tabelle output moderne
  "kableExtra",     # Tabelle HTML/LaTeX
  "haven",          # Import/export formati statistici
  "janitor"         # Pulizia nomi variabili
)

# Installazione automatica dei pacchetti mancanti
pacchetti_mancanti <- pacchetti_necessari[!(pacchetti_necessari %in% installed.packages()[,"Package"])]
if(length(pacchetti_mancanti) > 0) {
  install.packages(pacchetti_mancanti, dependencies = TRUE)
}

# Caricamento librerie
suppressPackageStartupMessages({
  library(tidyverse)
  library(readxl)
  library(lubridate)
  library(broom)
  library(stargazer)
  library(ggplot2)
  library(scales)
  library(fixest)
  library(modelsummary)
  library(kableExtra)
  library(haven)
  library(janitor)
})

cat("✓ Librerie caricate con successo\n\n")


# CONFIGURAZIONE E PARAMETRI ===================================================

# Directory di lavoro (modificare secondo necessità)
# setwd("path/to/your/project")

# Parametri dell'analisi
TRATTAMENTO_DATA <- as.Date("2022-02-24")  # Inizio conflitto Russia-Ucraina
TRATTAMENTO_ANNO <- 2022

# Codici ATECO
ATECO_TREATMENT_1 <- c(10, 11)                    # Agroalimentare + Bevande
ATECO_CONTROL_1   <- c(13, 14, 15, 16, 17, 18, 22, 25)  # Altri manifatturieri
ATECO_TREATMENT_2 <- c(10)                        # Solo alimentare
ATECO_CONTROL_2   <- c(11)                        # Solo bevande

# Livello di confidenza
CONF_LEVEL <- 0.95

# Crea cartelle per output
dir.create("output", showWarnings = FALSE)
dir.create("output/tabelle", showWarnings = FALSE)
dir.create("output/grafici", showWarnings = FALSE)
dir.create("output/dati_preparati", showWarnings = FALSE)

cat("✓ Configurazione completata\n")
cat(sprintf("  - Data trattamento: %s\n", TRATTAMENTO_DATA))
cat(sprintf("  - Anno trattamento: %d\n\n", TRATTAMENTO_ANNO))


# FUNZIONI DI UTILITÀ ==========================================================

#' Carica e prepara i dati dal file Excel AIDA
#'
#' @param file_path Percorso del file Excel
#' @param sheet_name Nome del foglio Excel (opzionale)
#' @return Dataframe pulito e preparato
carica_dati_aida <- function(file_path, sheet_name = NULL) {
  
  cat(sprintf("Caricamento dati da: %s\n", file_path))
  
  # Carica il file Excel
  if (is.null(sheet_name)) {
    df <- read_excel(file_path)
  } else {
    df <- read_excel(file_path, sheet = sheet_name)
  }
  
  # Pulizia nomi variabili (minuscole, senza spazi)
  df <- clean_names(df)
  
  cat(sprintf("✓ Caricati %s osservazioni e %s variabili\n", 
              format(nrow(df), big.mark = "."),
              ncol(df)))
  
  return(df)
}


#' Prepara il dataset per l'analisi DiD
#'
#' @param df Dataset grezzo da AIDA
#' @return Dataset preparato con variabili treatment e post
prepara_dati_did <- function(df) {
  
  cat("\nPreparazione dati per analisi DiD...\n")
  
  # Verifica variabili essenziali (adattare ai nomi reali del dataset AIDA)
  variabili_richieste <- c("anno", "ateco_2", "costo_lavoro", 
                          "dipendenti", "valore_aggiunto", "id_azienda")
  
  # Nota: questa è una lista indicativa. L'utente dovrà adattare i nomi 
  # delle variabili a quelli reali presenti nel file AIDA
  
  df_prep <- df %>%
    # Rimuovi osservazioni con valori mancanti nelle variabili chiave
    drop_na(anno, ateco_2) %>%
    
    # Crea variabile ATECO a 2 cifre (se necessario)
    mutate(
      ateco_2digit = as.integer(ateco_2),
      
      # Variabile POST: 1 se anno >= 2022, 0 altrimenti
      post = if_else(anno >= TRATTAMENTO_ANNO, 1, 0),
      
      # --- ANALISI 1: Agroalimentare (10+11) vs Altri manifatturieri ---
      treatment_1 = if_else(ateco_2digit %in% ATECO_TREATMENT_1, 1, 0),
      control_1 = if_else(ateco_2digit %in% ATECO_CONTROL_1, 1, 0),
      incluso_analisi_1 = if_else(treatment_1 == 1 | control_1 == 1, 1, 0),
      
      # --- ANALISI 2: Alimentare (10) vs Bevande (11) ---
      treatment_2 = if_else(ateco_2digit %in% ATECO_TREATMENT_2, 1, 0),
      control_2 = if_else(ateco_2digit %in% ATECO_CONTROL_2, 1, 0),
      incluso_analisi_2 = if_else(treatment_2 == 1 | control_2 == 1, 1, 0),
      
      # Interazione treatment × post (effetto DiD)
      treat_post_1 = treatment_1 * post,
      treat_post_2 = treatment_2 * post
    )
  
  # Calcola produttività (se non già presente)
  if ("produttivita" %in% names(df_prep)) {
    cat("  ✓ Variabile produttività già presente\n")
  } else if ("valore_aggiunto" %in% names(df_prep) & "dipendenti" %in% names(df_prep)) {
    df_prep <- df_prep %>%
      mutate(produttivita = valore_aggiunto / dipendenti)
    cat("  ✓ Calcolata produttività = Valore Aggiunto / Dipendenti\n")
  } else {
    cat("  ⚠ ATTENZIONE: Impossibile calcolare produttività\n")
  }
  
  # Converti in logaritmo per interpretazione percentuale (opzionale ma consigliato)
  df_prep <- df_prep %>%
    mutate(
      log_costo_lavoro = log(costo_lavoro + 1),
      log_dipendenti = log(dipendenti + 1),
      log_produttivita = log(produttivita + 1)
    )
  
  # Statistiche descrittive
  cat(sprintf("\n  Analisi 1 - Osservazioni incluse: %s\n", 
              format(sum(df_prep$incluso_analisi_1), big.mark = ".")))
  cat(sprintf("    • Treatment (ATECO 10+11): %s\n", 
              format(sum(df_prep$treatment_1), big.mark = ".")))
  cat(sprintf("    • Control (ATECO 13-18,22,25): %s\n", 
              format(sum(df_prep$control_1), big.mark = ".")))
  
  cat(sprintf("\n  Analisi 2 - Osservazioni incluse: %s\n", 
              format(sum(df_prep$incluso_analisi_2), big.mark = ".")))
  cat(sprintf("    • Treatment (ATECO 10): %s\n", 
              format(sum(df_prep$treatment_2), big.mark = ".")))
  cat(sprintf("    • Control (ATECO 11): %s\n", 
              format(sum(df_prep$control_2), big.mark = ".")))
  
  cat(sprintf("\n  Periodo pre-trattamento: %d-%d\n", 
              min(df_prep$anno), TRATTAMENTO_ANNO - 1))
  cat(sprintf("  Periodo post-trattamento: %d-%d\n\n", 
              TRATTAMENTO_ANNO, max(df_prep$anno)))
  
  return(df_prep)
}


#' Stima modello Difference-in-Differences
#'
#' @param df Dataset preparato
#' @param outcome_var Nome della variabile dipendente
#' @param treatment_var Nome della variabile treatment (treatment_1 o treatment_2)
#' @param analisi_id Identificativo dell'analisi (1 o 2)
#' @param cluster_var Variabile per cluster standard errors (opzionale)
#' @return Oggetto modello stimato
stima_did <- function(df, outcome_var, treatment_var, analisi_id = 1, cluster_var = NULL) {
  
  # Filtra dataset per l'analisi specifica
  if (analisi_id == 1) {
    df_analisi <- df %>% filter(incluso_analisi_1 == 1)
    interaction_var <- "treat_post_1"
  } else {
    df_analisi <- df %>% filter(incluso_analisi_2 == 1)
    interaction_var <- "treat_post_2"
  }
  
  # Formula del modello DiD classico
  # Y_it = β0 + β1*Treatment_i + β2*Post_t + β3*(Treatment_i × Post_t) + ε_it
  # Il coefficiente β3 è l'effetto causale stimato (ATT)
  
  formula_str <- sprintf("%s ~ %s + post + %s", 
                         outcome_var, treatment_var, interaction_var)
  
  # Stima il modello con OLS (o con fixed effects se specificato)
  if (!is.null(cluster_var)) {
    # Con cluster standard errors
    modello <- feols(as.formula(formula_str), 
                     data = df_analisi, 
                     cluster = cluster_var)
  } else {
    # OLS standard
    modello <- feols(as.formula(formula_str), 
                     data = df_analisi)
  }
  
  return(modello)
}


#' Stima modelli DiD con effetti fissi azienda e anno
#'
#' @param df Dataset preparato
#' @param outcome_var Nome della variabile dipendente
#' @param treatment_var Nome della variabile treatment
#' @param analisi_id Identificativo dell'analisi
#' @return Oggetto modello con fixed effects
stima_did_fe <- function(df, outcome_var, treatment_var, analisi_id = 1) {
  
  # Filtra dataset
  if (analisi_id == 1) {
    df_analisi <- df %>% filter(incluso_analisi_1 == 1)
    interaction_var <- "treat_post_1"
  } else {
    df_analisi <- df %>% filter(incluso_analisi_2 == 1)
    interaction_var <- "treat_post_2"
  }
  
  # Modello con fixed effects per azienda e anno
  # Y_it = β3*(Treatment_i × Post_t) + α_i + γ_t + ε_it
  # dove α_i sono fixed effects per azienda, γ_t per anno
  
  formula_str <- sprintf("%s ~ %s | id_azienda + anno", 
                         outcome_var, interaction_var)
  
  modello_fe <- feols(as.formula(formula_str), 
                      data = df_analisi, 
                      cluster = "id_azienda")
  
  return(modello_fe)
}


#' Crea grafici per verificare l'assunzione di parallel trends
#'
#' @param df Dataset preparato
#' @param outcome_var Nome della variabile dipendente
#' @param analisi_id Identificativo dell'analisi (1 o 2)
#' @param save_path Percorso per salvare il grafico
#' @return Oggetto ggplot
grafico_parallel_trends <- function(df, outcome_var, analisi_id = 1, save_path = NULL) {
  
  # Filtra e prepara i dati
  if (analisi_id == 1) {
    df_plot <- df %>% 
      filter(incluso_analisi_1 == 1) %>%
      mutate(gruppo = if_else(treatment_1 == 1, 
                              "Treatment: ATECO 10+11", 
                              "Control: ATECO 13-18,22,25"))
  } else {
    df_plot <- df %>% 
      filter(incluso_analisi_2 == 1) %>%
      mutate(gruppo = if_else(treatment_2 == 1, 
                              "Treatment: ATECO 10", 
                              "Control: ATECO 11"))
  }
  
  # Calcola medie annuali per gruppo
  trend_data <- df_plot %>%
    group_by(anno, gruppo) %>%
    summarise(
      media = mean(!!sym(outcome_var), na.rm = TRUE),
      se = sd(!!sym(outcome_var), na.rm = TRUE) / sqrt(n()),
      .groups = "drop"
    )
  
  # Crea il grafico
  p <- ggplot(trend_data, aes(x = anno, y = media, color = gruppo, group = gruppo)) +
    geom_line(size = 1.2) +
    geom_point(size = 3) +
    geom_vline(xintercept = TRATTAMENTO_ANNO - 0.5, 
               linetype = "dashed", color = "red", size = 1) +
    annotate("text", x = TRATTAMENTO_ANNO, y = max(trend_data$media) * 0.95,
             label = "Inizio conflitto\n(24 feb 2022)", 
             color = "red", size = 3.5, hjust = 0) +
    labs(
      title = sprintf("Parallel Trends Check - %s", outcome_var),
      subtitle = sprintf("Analisi %d: Verifica dell'assunzione di trend paralleli pre-trattamento", analisi_id),
      x = "Anno",
      y = sprintf("Media %s", outcome_var),
      color = "Gruppo"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      legend.position = "bottom",
      plot.title = element_text(face = "bold", size = 14),
      panel.grid.minor = element_blank()
    ) +
    scale_color_manual(values = c("Treatment: ATECO 10+11" = "#E74C3C",
                                   "Control: ATECO 13-18,22,25" = "#3498DB",
                                   "Treatment: ATECO 10" = "#E74C3C",
                                   "Control: ATECO 11" = "#3498DB"))
  
  # Salva il grafico se specificato
  if (!is.null(save_path)) {
    ggsave(save_path, plot = p, width = 10, height = 6, dpi = 300)
    cat(sprintf("  ✓ Grafico salvato: %s\n", save_path))
  }
  
  return(p)
}


#' Stima effetti dinamici del trattamento (event study)
#'
#' @param df Dataset preparato
#' @param outcome_var Nome della variabile dipendente
#' @param analisi_id Identificativo dell'analisi
#' @return Oggetto modello event study
stima_event_study <- function(df, outcome_var, analisi_id = 1) {
  
  # Filtra dataset
  if (analisi_id == 1) {
    df_analisi <- df %>% 
      filter(incluso_analisi_1 == 1) %>%
      mutate(treatment = treatment_1)
  } else {
    df_analisi <- df %>% 
      filter(incluso_analisi_2 == 1) %>%
      mutate(treatment = treatment_2)
  }
  
  # Crea variabili relative al tempo del trattamento
  df_analisi <- df_analisi %>%
    mutate(
      anni_dal_trattamento = anno - TRATTAMENTO_ANNO,
      # Interazioni treatment × anno relativo (escluso anno -1 come riferimento)
      rel_time = case_when(
        anni_dal_trattamento < -1 ~ paste0("t_", abs(anni_dal_trattamento)),
        anni_dal_trattamento == -1 ~ "riferimento",
        anni_dal_trattamento >= 0 ~ paste0("t_plus_", anni_dal_trattamento)
      )
    )
  
  # Crea dummy per ogni periodo relativo
  anni_relativi <- unique(df_analisi$anni_dal_trattamento)
  anni_relativi <- anni_relativi[anni_relativi != -1]  # Escludi anno riferimento
  
  for (anno_rel in anni_relativi) {
    var_name <- if_else(anno_rel < 0, 
                       paste0("lead_", abs(anno_rel)),
                       paste0("lag_", anno_rel))
    df_analisi[[var_name]] <- (df_analisi$anni_dal_trattamento == anno_rel) * df_analisi$treatment
  }
  
  # Formula del modello event study
  lead_lag_vars <- paste(names(df_analisi)[grepl("^(lead_|lag_)", names(df_analisi))], 
                         collapse = " + ")
  formula_str <- sprintf("%s ~ %s | id_azienda + anno", outcome_var, lead_lag_vars)
  
  # Stima il modello
  modello_es <- feols(as.formula(formula_str), 
                      data = df_analisi, 
                      cluster = "id_azienda")
  
  return(modello_es)
}


#' Crea grafico degli effetti dinamici (event study plot)
#'
#' @param modello Modello event study stimato
#' @param save_path Percorso per salvare il grafico
#' @return Oggetto ggplot
grafico_event_study <- function(modello, save_path = NULL) {
  
  # Estrai coefficienti e standard errors
  coef_df <- tidy(modello, conf.int = TRUE, conf.level = CONF_LEVEL) %>%
    filter(grepl("^(lead_|lag_)", term)) %>%
    mutate(
      periodo = as.integer(str_extract(term, "\\d+")),
      periodo = if_else(grepl("lead", term), -periodo, periodo)
    ) %>%
    arrange(periodo)
  
  # Aggiungi punto di riferimento (anno -1, coefficiente = 0)
  riferimento <- data.frame(
    term = "riferimento",
    estimate = 0,
    std.error = 0,
    conf.low = 0,
    conf.high = 0,
    periodo = -1
  )
  
  coef_df <- bind_rows(coef_df, riferimento) %>%
    arrange(periodo)
  
  # Crea il grafico
  p <- ggplot(coef_df, aes(x = periodo, y = estimate)) +
    geom_point(size = 3, color = "#E74C3C") +
    geom_errorbar(aes(ymin = conf.low, ymax = conf.high), 
                  width = 0.2, size = 1, color = "#E74C3C") +
    geom_line(color = "#E74C3C", size = 1) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "red", size = 1) +
    labs(
      title = "Effetti Dinamici del Trattamento (Event Study)",
      subtitle = "Coefficienti stimati per ogni anno relativo all'inizio del conflitto",
      x = "Anni relativi al trattamento (0 = 2022)",
      y = "Coefficiente stimato",
      caption = sprintf("Note: Barre di errore rappresentano intervalli di confidenza al %d%%.\nAnno -1 è il periodo di riferimento (coefficiente = 0).", 
                       as.integer(CONF_LEVEL * 100))
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      panel.grid.minor = element_blank()
    ) +
    scale_x_continuous(breaks = seq(min(coef_df$periodo), max(coef_df$periodo), by = 1))
  
  # Salva il grafico
  if (!is.null(save_path)) {
    ggsave(save_path, plot = p, width = 10, height = 6, dpi = 300)
    cat(sprintf("  ✓ Grafico event study salvato: %s\n", save_path))
  }
  
  return(p)
}


#' Crea tabella riassuntiva dei risultati DiD
#'
#' @param modelli Lista di modelli stimati
#' @param nomi_modelli Nomi descrittivi dei modelli
#' @param output_path Percorso per salvare la tabella
#' @param formato Formato output ("html", "latex", "text")
crea_tabella_risultati <- function(modelli, nomi_modelli, output_path = NULL, formato = "html") {
  
  # Usa modelsummary per creare tabelle professionali
  tabella <- modelsummary(
    modelli,
    stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
    statistic = 'std.error',
    fmt = 3,
    coef_rename = c(
      "treat_post_1" = "Treatment × Post (DiD)",
      "treat_post_2" = "Treatment × Post (DiD)",
      "treatment_1" = "Treatment",
      "treatment_2" = "Treatment",
      "post" = "Post"
    ),
    gof_map = c("nobs", "r.squared", "adj.r.squared"),
    title = "Risultati Analisi Difference-in-Differences",
    notes = list(
      "Note: Errori standard tra parentesi.",
      "*** p<0.01, ** p<0.05, * p<0.1",
      "Il coefficiente 'Treatment × Post' rappresenta l'effetto causale stimato (ATT)."
    ),
    output = formato
  )
  
  # Salva la tabella
  if (!is.null(output_path)) {
    if (formato == "html") {
      tabella %>%
        kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
        save_kable(file = output_path)
    } else if (formato == "latex") {
      writeLines(tabella, output_path)
    } else {
      writeLines(capture.output(tabella), output_path)
    }
    cat(sprintf("  ✓ Tabella salvata: %s\n", output_path))
  }
  
  return(tabella)
}


# ANALISI PRINCIPALE ===========================================================

#' Funzione principale che esegue l'intera analisi DiD
#'
#' @param file_path Percorso del file Excel con i dati AIDA
#' @param sheet_name Nome del foglio Excel (opzionale)
esegui_analisi_completa <- function(file_path, sheet_name = NULL) {
  
  cat("\n")
  cat("================================================================================\n")
  cat("  ANALISI DIFFERENCE-IN-DIFFERENCES\n")
  cat("  Impatto Conflitto Russia-Ucraina sul Settore Agroalimentare Italiano\n")
  cat("================================================================================\n\n")
  
  # 1. CARICAMENTO DATI --------------------------------------------------------
  cat("FASE 1: Caricamento dati\n")
  cat("--------------------------------------------------------------------------------\n")
  df_raw <- carica_dati_aida(file_path, sheet_name)
  
  
  # 2. PREPARAZIONE DATI -------------------------------------------------------
  cat("\nFASE 2: Preparazione dati\n")
  cat("--------------------------------------------------------------------------------\n")
  df <- prepara_dati_did(df_raw)
  
  # Salva dataset preparato
  saveRDS(df, "output/dati_preparati/dataset_did_preparato.rds")
  write_csv(df, "output/dati_preparati/dataset_did_preparato.csv")
  cat("  ✓ Dataset preparato salvato in output/dati_preparati/\n")
  
  
  # 3. ANALISI 1: ATECO 10+11 vs 13-18,22,25 ----------------------------------
  cat("\n\nFASE 3: ANALISI 1 - Agroalimentare (10+11) vs Altri Manifatturieri\n")
  cat("================================================================================\n")
  
  # Variabili dipendenti da analizzare
  outcome_vars_1 <- c("log_costo_lavoro", "log_dipendenti", "log_produttivita")
  outcome_labels_1 <- c("Log(Costo Lavoro)", "Log(Dipendenti)", "Log(Produttività)")
  
  # Stima modelli DiD base
  cat("\nStima modelli DiD (OLS)...\n")
  modelli_did_1_base <- list()
  for (i in seq_along(outcome_vars_1)) {
    var <- outcome_vars_1[i]
    cat(sprintf("  • %s\n", outcome_labels_1[i]))
    modelli_did_1_base[[var]] <- stima_did(df, var, "treatment_1", analisi_id = 1)
  }
  
  # Stima modelli con fixed effects
  cat("\nStima modelli DiD con Fixed Effects (azienda + anno)...\n")
  modelli_did_1_fe <- list()
  for (i in seq_along(outcome_vars_1)) {
    var <- outcome_vars_1[i]
    cat(sprintf("  • %s\n", outcome_labels_1[i]))
    modelli_did_1_fe[[var]] <- stima_did_fe(df, var, "treatment_1", analisi_id = 1)
  }
  
  # Crea tabella risultati
  cat("\nCreazione tabelle risultati...\n")
  
  # Tabella modelli base
  crea_tabella_risultati(
    modelli_did_1_base,
    names(modelli_did_1_base),
    output_path = "output/tabelle/analisi1_did_base.html",
    formato = "html"
  )
  
  # Tabella modelli fixed effects
  crea_tabella_risultati(
    modelli_did_1_fe,
    names(modelli_did_1_fe),
    output_path = "output/tabelle/analisi1_did_fixed_effects.html",
    formato = "html"
  )
  
  # Verifica parallel trends
  cat("\nCreazione grafici parallel trends...\n")
  for (i in seq_along(outcome_vars_1)) {
    var <- outcome_vars_1[i]
    label <- outcome_labels_1[i]
    
    grafico_parallel_trends(
      df, var, analisi_id = 1,
      save_path = sprintf("output/grafici/analisi1_parallel_trends_%s.png", var)
    )
  }
  
  # Event study (se ci sono abbastanza anni di dati)
  anni_unici <- length(unique(df$anno))
  if (anni_unici >= 5) {
    cat("\nStima effetti dinamici (event study)...\n")
    for (i in seq_along(outcome_vars_1)) {
      var <- outcome_vars_1[i]
      cat(sprintf("  • %s\n", outcome_labels_1[i]))
      
      tryCatch({
        modello_es <- stima_event_study(df, var, analisi_id = 1)
        grafico_event_study(
          modello_es,
          save_path = sprintf("output/grafici/analisi1_event_study_%s.png", var)
        )
      }, error = function(e) {
        cat(sprintf("    ⚠ Impossibile stimare event study per %s: %s\n", var, e$message))
      })
    }
  } else {
    cat("\n  ⚠ Insufficienti anni di dati per event study (minimo 5 anni richiesti)\n")
  }
  
  
  # 4. ANALISI 2: ATECO 10 vs 11 ----------------------------------------------
  cat("\n\nFASE 4: ANALISI 2 - Alimentare (10) vs Bevande (11)\n")
  cat("================================================================================\n")
  
  outcome_vars_2 <- c("log_costo_lavoro", "log_dipendenti", "log_produttivita")
  outcome_labels_2 <- c("Log(Costo Lavoro)", "Log(Dipendenti)", "Log(Produttività)")
  
  # Stima modelli DiD base
  cat("\nStima modelli DiD (OLS)...\n")
  modelli_did_2_base <- list()
  for (i in seq_along(outcome_vars_2)) {
    var <- outcome_vars_2[i]
    cat(sprintf("  • %s\n", outcome_labels_2[i]))
    modelli_did_2_base[[var]] <- stima_did(df, var, "treatment_2", analisi_id = 2)
  }
  
  # Stima modelli con fixed effects
  cat("\nStima modelli DiD con Fixed Effects...\n")
  modelli_did_2_fe <- list()
  for (i in seq_along(outcome_vars_2)) {
    var <- outcome_vars_2[i]
    cat(sprintf("  • %s\n", outcome_labels_2[i]))
    modelli_did_2_fe[[var]] <- stima_did_fe(df, var, "treatment_2", analisi_id = 2)
  }
  
  # Crea tabella risultati
  cat("\nCreazione tabelle risultati...\n")
  
  crea_tabella_risultati(
    modelli_did_2_base,
    names(modelli_did_2_base),
    output_path = "output/tabelle/analisi2_did_base.html",
    formato = "html"
  )
  
  crea_tabella_risultati(
    modelli_did_2_fe,
    names(modelli_did_2_fe),
    output_path = "output/tabelle/analisi2_did_fixed_effects.html",
    formato = "html"
  )
  
  # Parallel trends
  cat("\nCreazione grafici parallel trends...\n")
  for (i in seq_along(outcome_vars_2)) {
    var <- outcome_vars_2[i]
    
    grafico_parallel_trends(
      df, var, analisi_id = 2,
      save_path = sprintf("output/grafici/analisi2_parallel_trends_%s.png", var)
    )
  }
  
  # Event study
  if (anni_unici >= 5) {
    cat("\nStima effetti dinamici (event study)...\n")
    for (i in seq_along(outcome_vars_2)) {
      var <- outcome_vars_2[i]
      cat(sprintf("  • %s\n", outcome_labels_2[i]))
      
      tryCatch({
        modello_es <- stima_event_study(df, var, analisi_id = 2)
        grafico_event_study(
          modello_es,
          save_path = sprintf("output/grafici/analisi2_event_study_%s.png", var)
        )
      }, error = function(e) {
        cat(sprintf("    ⚠ Impossibile stimare event study per %s: %s\n", var, e$message))
      })
    }
  }
  
  
  # 5. RIEPILOGO FINALE --------------------------------------------------------
  cat("\n\n")
  cat("================================================================================\n")
  cat("  ANALISI COMPLETATA\n")
  cat("================================================================================\n\n")
  
  cat("Output generati:\n")
  cat("  • Dati preparati: output/dati_preparati/\n")
  cat("  • Tabelle risultati: output/tabelle/\n")
  cat("  • Grafici: output/grafici/\n\n")
  
  cat("Prossimi passi:\n")
  cat("  1. Verificare i grafici parallel trends per validare l'assunzione DiD\n")
  cat("  2. Interpretare i coefficienti 'Treatment × Post' nelle tabelle\n")
  cat("  3. Analizzare gli effetti dinamici (event study) se disponibili\n")
  cat("  4. Considerare analisi di robustezza (es. placebo tests, sub-campioni)\n\n")
  
  # Ritorna lista con tutti i risultati
  risultati <- list(
    dati = df,
    analisi_1 = list(
      modelli_base = modelli_did_1_base,
      modelli_fe = modelli_did_1_fe
    ),
    analisi_2 = list(
      modelli_base = modelli_did_2_base,
      modelli_fe = modelli_did_2_fe
    )
  )
  
  return(invisible(risultati))
}


# ESEMPIO DI UTILIZZO ==========================================================

# Decommentare e modificare il percorso del file quando si hanno i dati reali
# 
# risultati <- esegui_analisi_completa(
#   file_path = "dati/database_aida_2017_2024.xlsx",
#   sheet_name = "Dati"  # Opzionale
# )
#
# Accedere ai risultati:
# risultati$analisi_1$modelli_fe$log_costo_lavoro  # Modello specifico
# summary(risultati$analisi_1$modelli_fe$log_costo_lavoro)  # Summary dettagliato


# NOTE IMPORTANTI ==============================================================
#
# 1. NOMI VARIABILI:
#    Prima di eseguire l'analisi, verificare che i nomi delle variabili nel
#    file Excel AIDA corrispondano a quelli utilizzati nello script.
#    Le variabili richieste sono:
#      - anno (o year)
#      - ateco_2 (codice ATECO a 2 cifre)
#      - id_azienda (identificativo univoco azienda)
#      - costo_lavoro (o stipendi_totali, salari)
#      - dipendenti (numero dipendenti)
#      - valore_aggiunto (per calcolare produttività)
#
#    Se i nomi sono diversi, modificare la funzione prepara_dati_did().
#
# 2. INTERPRETAZIONE COEFFICIENTI:
#    Utilizzando log come variabile dipendente, il coefficiente DiD può essere
#    interpretato come variazione percentuale:
#    - Coeff = 0.05 → +5% di incremento nel gruppo treatment rispetto al control
#    - Coeff = -0.03 → -3% di riduzione nel gruppo treatment rispetto al control
#
# 3. ASSUNZIONI DiD:
#    - Parallel trends: verificare visivamente dai grafici che i trend pre-trattamento
#      siano paralleli tra treatment e control
#    - No anticipazione: le imprese non devono aver modificato il comportamento
#      prima del 24 febbraio 2022
#    - Composizione stabile: preferibilmente un panel bilanciato
#
# 4. ESTENSIONI POSSIBILI:
#    - Aggiungere covariates di controllo (dimensione azienda, regione, ecc.)
#    - Testare eterogeneità degli effetti (per dimensione, localizzazione)
#    - Placebo tests (date false di trattamento)
#    - Matching pre-processing per migliorare comparabilità
#
################################################################################

cat("\n✓ Script caricato con successo!\n")
cat("Per eseguire l'analisi, chiamare:\n")
cat("  esegui_analisi_completa('percorso/del/file.xlsx')\n\n")

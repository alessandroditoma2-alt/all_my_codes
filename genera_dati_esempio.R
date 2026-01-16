################################################################################
# SCRIPT PER GENERARE DATI DI ESEMPIO
# Per testare l'analisi DiD senza avere il database AIDA reale
#
# Autore: Alessandro Di Toma
# Descrizione: Crea un dataset simulato con struttura simile al database AIDA
################################################################################

library(tidyverse)
library(writexl)

set.seed(42)  # Per riproducibilità

# PARAMETRI SIMULAZIONE ========================================================

n_aziende <- 500        # Numero di aziende
anni <- 2017:2024       # Periodo temporale
n_anni <- length(anni)

# Codici ATECO
ateco_codes <- c(
  rep(10, 150),  # 150 aziende alimentari
  rep(11, 100),  # 100 aziende bevande
  rep(13, 50),   # 50 aziende tessili
  rep(14, 30),   # 30 aziende abbigliamento
  rep(15, 30),   # 30 aziende pelle
  rep(16, 30),   # 30 aziende legno
  rep(17, 30),   # 30 aziende carta
  rep(18, 30),   # 30 aziende stampa
  rep(22, 25),   # 25 aziende gomma/plastica
  rep(25, 25)    # 25 aziende metalli
)


# GENERA CARATTERISTICHE AZIENDE ===============================================

aziende <- tibble(
  id_azienda = sprintf("AZIENDA%04d", 1:n_aziende),
  ateco_2 = ateco_codes,
  regione = sample(c("Lombardia", "Veneto", "Emilia-Romagna", "Piemonte", 
                     "Toscana", "Lazio", "Campania", "Puglia", "Sicilia"), 
                   n_aziende, replace = TRUE),
  dimensione = sample(c("Piccola", "Media", "Grande"), 
                      n_aziende, replace = TRUE, 
                      prob = c(0.6, 0.3, 0.1)),
  
  # Caratteristiche baseline (2017)
  dipendenti_base = case_when(
    dimensione == "Piccola" ~ round(rnorm(n_aziende, 20, 8)),
    dimensione == "Media" ~ round(rnorm(n_aziende, 80, 20)),
    dimensione == "Grande" ~ round(rnorm(n_aziende, 250, 60))
  ),
  
  costo_lavoro_base = dipendenti_base * rnorm(n_aziende, 30000, 5000),
  valore_aggiunto_base = costo_lavoro_base * rnorm(n_aziende, 2.5, 0.5)
) %>%
  mutate(
    dipendenti_base = pmax(dipendenti_base, 5),  # Minimo 5 dipendenti
    costo_lavoro_base = pmax(costo_lavoro_base, 150000),  # Minimo 150k€
    valore_aggiunto_base = pmax(valore_aggiunto_base, 200000)  # Minimo 200k€
  )


# GENERA PANEL DATA ============================================================

# Crea dataset panel (azienda × anno)
df_panel <- expand_grid(
  id_azienda = aziende$id_azienda,
  anno = anni
) %>%
  left_join(aziende, by = "id_azienda")


# SIMULA TREND TEMPORALI =======================================================

# Trend generale (uguale per tutti)
trend_generale <- tibble(
  anno = anni,
  crescita_generale = c(0.02, 0.03, 0.025, 0.02, 0.01,  # 2017-2021 pre-COVID/conflitto
                        0.04, 0.05, 0.03)                 # 2022-2024 post-conflitto
)

# Trend settoriali (diversi per treatment e control)
trend_settoriale <- tibble(
  ateco_2 = unique(ateco_codes),
  trend_settoriale_annuo = case_when(
    ateco_2 %in% c(10, 11) ~ 0.015,   # Agroalimentare crescita moderata
    TRUE ~ 0.025                       # Altri settori crescita più alta
  )
)


# EFFETTO DEL CONFLITTO (DiD) ==================================================

# L'effetto del conflitto è NEGATIVO per il settore agroalimentare
# Questo è ciò che l'analisi DiD dovrebbe rilevare

effetto_conflitto <- tibble(
  ateco_2 = unique(ateco_codes),
  effetto_2022 = case_when(
    ateco_2 == 10 ~ -0.08,   # Alimentare: -8% (più colpito)
    ateco_2 == 11 ~ -0.04,   # Bevande: -4% (meno colpito)
    TRUE ~ 0                 # Altri settori: nessun effetto diretto
  ),
  effetto_2023 = case_when(
    ateco_2 == 10 ~ -0.06,   # Effetto persiste ma si attenua
    ateco_2 == 11 ~ -0.02,
    TRUE ~ 0
  ),
  effetto_2024 = case_when(
    ateco_2 == 10 ~ -0.03,   # Ulteriore attenuazione
    ateco_2 == 11 ~ 0,
    TRUE ~ 0
  )
)


# GENERA VARIABILI DIPENDENTI ==================================================

df_simulato <- df_panel %>%
  left_join(trend_generale, by = "anno") %>%
  left_join(trend_settoriale, by = "ateco_2") %>%
  left_join(effetto_conflitto, by = "ateco_2") %>%
  
  # Calcola anni trascorsi dal baseline
  mutate(anni_da_base = anno - min(anni)) %>%
  
  # Simula DIPENDENTI
  mutate(
    # Trend base + rumore
    dipendenti = dipendenti_base * 
      (1 + crescita_generale + trend_settoriale_annuo * anni_da_base + rnorm(n(), 0, 0.02)),
    
    # Applica effetto conflitto
    dipendenti = case_when(
      anno == 2022 ~ dipendenti * (1 + effetto_2022),
      anno == 2023 ~ dipendenti * (1 + effetto_2022 + effetto_2023),
      anno == 2024 ~ dipendenti * (1 + effetto_2022 + effetto_2023 + effetto_2024),
      TRUE ~ dipendenti
    ),
    dipendenti = round(pmax(dipendenti, 5))  # Minimo 5 dipendenti
  ) %>%
  
  # Simula COSTO DEL LAVORO
  mutate(
    costo_lavoro = costo_lavoro_base * 
      (1 + crescita_generale * 1.5 + trend_settoriale_annuo * anni_da_base + rnorm(n(), 0, 0.03)),
    
    # Applica effetto conflitto (più forte sui salari)
    costo_lavoro = case_when(
      anno == 2022 ~ costo_lavoro * (1 + effetto_2022 * 1.2),
      anno == 2023 ~ costo_lavoro * (1 + effetto_2022 * 1.2 + effetto_2023 * 1.2),
      anno == 2024 ~ costo_lavoro * (1 + effetto_2022 * 1.2 + effetto_2023 * 1.2 + effetto_2024 * 1.2),
      TRUE ~ costo_lavoro
    ),
    costo_lavoro = round(pmax(costo_lavoro, 100000))
  ) %>%
  
  # Simula VALORE AGGIUNTO
  mutate(
    valore_aggiunto = valore_aggiunto_base * 
      (1 + crescita_generale * 2 + trend_settoriale_annuo * anni_da_base + rnorm(n(), 0, 0.05)),
    
    # Applica effetto conflitto
    valore_aggiunto = case_when(
      anno == 2022 ~ valore_aggiunto * (1 + effetto_2022 * 1.5),
      anno == 2023 ~ valore_aggiunto * (1 + effetto_2022 * 1.5 + effetto_2023 * 1.5),
      anno == 2024 ~ valore_aggiunto * (1 + effetto_2022 * 1.5 + effetto_2023 * 1.5 + effetto_2024 * 1.5),
      TRUE ~ valore_aggiunto
    ),
    valore_aggiunto = round(pmax(valore_aggiunto, 150000))
  ) %>%
  
  # Calcola PRODUTTIVITÀ
  mutate(
    produttivita = valore_aggiunto / dipendenti
  ) %>%
  
  # Seleziona variabili finali (come nel database AIDA)
  select(
    anno,
    id_azienda,
    ateco_2,
    regione,
    dimensione,
    dipendenti,
    costo_lavoro,
    valore_aggiunto,
    produttivita
  ) %>%
  arrange(id_azienda, anno)


# AGGIUNGI ALCUNI MISSING VALUES (realistico) =================================

# Introduci 5% di missing values casuali
n_missing <- round(nrow(df_simulato) * 0.05)
missing_rows <- sample(1:nrow(df_simulato), n_missing)

df_simulato[missing_rows, "dipendenti"] <- NA
df_simulato[sample(1:nrow(df_simulato), n_missing), "costo_lavoro"] <- NA
df_simulato[sample(1:nrow(df_simulato), n_missing), "valore_aggiunto"] <- NA


# STATISTICHE DESCRITTIVE ======================================================

cat("\n")
cat("================================================================================\n")
cat("  DATASET SIMULATO GENERATO\n")
cat("================================================================================\n\n")

cat("Dimensioni dataset:\n")
cat(sprintf("  • Numero aziende: %d\n", n_distinct(df_simulato$id_azienda)))
cat(sprintf("  • Anni: %d-%d (%d anni)\n", min(anni), max(anni), n_anni))
cat(sprintf("  • Osservazioni totali: %s\n\n", format(nrow(df_simulato), big.mark = ".")))

cat("Distribuzione settori ATECO:\n")
df_simulato %>%
  distinct(id_azienda, ateco_2) %>%
  count(ateco_2) %>%
  arrange(ateco_2) %>%
  mutate(
    settore = case_when(
      ateco_2 == 10 ~ "Alimentare",
      ateco_2 == 11 ~ "Bevande",
      ateco_2 == 13 ~ "Tessile",
      ateco_2 == 14 ~ "Abbigliamento",
      ateco_2 == 15 ~ "Pelle",
      ateco_2 == 16 ~ "Legno",
      ateco_2 == 17 ~ "Carta",
      ateco_2 == 18 ~ "Stampa",
      ateco_2 == 22 ~ "Gomma/Plastica",
      ateco_2 == 25 ~ "Metalli"
    )
  ) %>%
  select(ateco_2, settore, n) %>%
  print()

cat("\nStatistiche descrittive variabili principali:\n")
df_simulato %>%
  summarise(
    across(c(dipendenti, costo_lavoro, valore_aggiunto, produttivita),
           list(media = ~mean(.x, na.rm = TRUE),
                mediana = ~median(.x, na.rm = TRUE),
                min = ~min(.x, na.rm = TRUE),
                max = ~max(.x, na.rm = TRUE)),
           .names = "{.col}_{.fn}")
  ) %>%
  pivot_longer(everything(), names_to = "statistica", values_to = "valore") %>%
  separate(statistica, into = c("variabile", "stat"), sep = "_(?=[^_]+$)") %>%
  pivot_wider(names_from = stat, values_from = valore) %>%
  print()

cat("\nEffetto simulato del conflitto (da rilevare con DiD):\n")
cat("  • ATECO 10 (Alimentare): -8% nel 2022, -6% nel 2023, -3% nel 2024\n")
cat("  • ATECO 11 (Bevande): -4% nel 2022, -2% nel 2023, 0% nel 2024\n")
cat("  • Altri settori: nessun effetto diretto\n\n")


# SALVA DATASET ================================================================

# Crea cartella dati se non esiste
dir.create("dati", showWarnings = FALSE)

# Salva in formato Excel (come AIDA)
write_xlsx(df_simulato, "dati/database_aida_simulato.xlsx")
cat("✓ Dataset salvato in: dati/database_aida_simulato.xlsx\n")

# Salva anche in formato CSV
write_csv(df_simulato, "dati/database_aida_simulato.csv")
cat("✓ Dataset salvato in: dati/database_aida_simulato.csv\n")

# Salva in formato RDS (più efficiente per R)
saveRDS(df_simulato, "dati/database_aida_simulato.rds")
cat("✓ Dataset salvato in: dati/database_aida_simulato.rds\n\n")


# CODICE PER TESTARE L'ANALISI =================================================

cat("Per testare l'analisi DiD con questi dati simulati:\n\n")
cat("  # 1. Caricare lo script principale\n")
cat("  source('did_analisi_russia_ucraina_agroalimentare.R')\n\n")
cat("  # 2. Eseguire l'analisi\n")
cat("  risultati <- esegui_analisi_completa(\n")
cat("    file_path = 'dati/database_aida_simulato.xlsx'\n")
cat("  )\n\n")
cat("  # 3. Visualizzare i risultati\n")
cat("  summary(risultati$analisi_1$modelli_fe$log_costo_lavoro)\n\n")

cat("I risultati dovrebbero mostrare un effetto negativo significativo\n")
cat("per il settore agroalimentare (ATECO 10+11) dopo il 2022.\n\n")


# VISUALIZZAZIONE PRELIMINARE ==================================================

cat("Creazione grafici preliminari...\n")

# Grafico 1: Trend occupazione per settore
p1 <- df_simulato %>%
  mutate(
    gruppo = case_when(
      ateco_2 %in% c(10, 11) ~ "Agroalimentare (10+11)",
      TRUE ~ "Altri settori"
    )
  ) %>%
  group_by(anno, gruppo) %>%
  summarise(dipendenti_medi = mean(dipendenti, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = anno, y = dipendenti_medi, color = gruppo, group = gruppo)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  geom_vline(xintercept = 2021.5, linetype = "dashed", color = "red") +
  annotate("text", x = 2022, y = max(df_simulato$dipendenti, na.rm = TRUE) * 0.9,
           label = "Conflitto", color = "red", hjust = 0) +
  labs(
    title = "Trend Occupazione: Agroalimentare vs Altri Settori",
    x = "Anno",
    y = "Numero medio dipendenti",
    color = "Settore"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("dati/preview_trend_occupazione.png", p1, width = 10, height = 6, dpi = 300)
cat("  ✓ Grafico salvato: dati/preview_trend_occupazione.png\n")


# Grafico 2: Trend costo lavoro per settore
p2 <- df_simulato %>%
  mutate(
    gruppo = case_when(
      ateco_2 %in% c(10, 11) ~ "Agroalimentare (10+11)",
      TRUE ~ "Altri settori"
    )
  ) %>%
  group_by(anno, gruppo) %>%
  summarise(costo_lavoro_medio = mean(costo_lavoro, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = anno, y = costo_lavoro_medio / 1000, color = gruppo, group = gruppo)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  geom_vline(xintercept = 2021.5, linetype = "dashed", color = "red") +
  annotate("text", x = 2022, y = max(df_simulato$costo_lavoro, na.rm = TRUE) / 1000 * 0.9,
           label = "Conflitto", color = "red", hjust = 0) +
  labs(
    title = "Trend Costo del Lavoro: Agroalimentare vs Altri Settori",
    x = "Anno",
    y = "Costo lavoro medio (migliaia €)",
    color = "Settore"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("dati/preview_trend_costo_lavoro.png", p2, width = 10, height = 6, dpi = 300)
cat("  ✓ Grafico salvato: dati/preview_trend_costo_lavoro.png\n")


cat("\n")
cat("================================================================================\n")
cat("  GENERAZIONE COMPLETATA\n")
cat("================================================================================\n\n")
cat("Ora puoi testare l'analisi DiD con il dataset simulato!\n\n")

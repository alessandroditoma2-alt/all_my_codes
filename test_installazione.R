################################################################################
# TEST INSTALLAZIONE E VERIFICA AMBIENTE R
# Script per verificare che tutto sia configurato correttamente
#
# Autore: Alessandro Di Toma
################################################################################

cat("\n")
cat("================================================================================\n")
cat("  TEST INSTALLAZIONE AMBIENTE R\n")
cat("  Verifica configurazione per analisi DiD\n")
cat("================================================================================\n\n")


# TEST 1: VERSIONE R ===========================================================
cat("TEST 1: Versione R\n")
cat("--------------------------------------------------------------------------------\n")

versione_r <- R.version.string
cat(sprintf("  ✓ %s\n", versione_r))

# Verifica che sia almeno R 4.0
r_version_num <- as.numeric(paste0(R.version$major, ".", R.version$minor))
if (r_version_num >= 4.0) {
  cat("  ✓ Versione adeguata (≥ 4.0)\n\n")
} else {
  cat("  ⚠ ATTENZIONE: Raccomandata versione R ≥ 4.0\n\n")
}


# TEST 2: LIBRERIE NECESSARIE ==================================================
cat("TEST 2: Verifica librerie\n")
cat("--------------------------------------------------------------------------------\n")

librerie_richieste <- c(
  "tidyverse", "readxl", "lubridate", "broom", "stargazer",
  "ggplot2", "scales", "fixest", "modelsummary", 
  "kableExtra", "haven", "janitor"
)

librerie_mancanti <- c()
librerie_installate <- c()

for (lib in librerie_richieste) {
  if (lib %in% installed.packages()[,"Package"]) {
    librerie_installate <- c(librerie_installate, lib)
    cat(sprintf("  ✓ %s\n", lib))
  } else {
    librerie_mancanti <- c(librerie_mancanti, lib)
    cat(sprintf("  ✗ %s (MANCANTE)\n", lib))
  }
}

cat("\n")
cat(sprintf("Riepilogo: %d/%d librerie installate\n", 
            length(librerie_installate), 
            length(librerie_richieste)))

if (length(librerie_mancanti) > 0) {
  cat("\nLibrerie mancanti:\n")
  for (lib in librerie_mancanti) {
    cat(sprintf("  - %s\n", lib))
  }
  cat("\nPer installarle, eseguire:\n")
  cat(sprintf("  install.packages(c(%s))\n\n", 
              paste0("'", librerie_mancanti, "'", collapse = ", ")))
  
  # Chiedi se installare ora
  cat("Vuoi installarle ora? (y/n): ")
  risposta <- readline()
  if (tolower(risposta) == "y" || tolower(risposta) == "yes") {
    cat("\nInstallazione in corso...\n")
    install.packages(librerie_mancanti, dependencies = TRUE)
    cat("✓ Installazione completata!\n\n")
  }
} else {
  cat("  ✓ Tutte le librerie sono installate!\n\n")
}


# TEST 3: CARICAMENTO LIBRERIE =================================================
cat("TEST 3: Caricamento librerie\n")
cat("--------------------------------------------------------------------------------\n")

errori_caricamento <- c()

for (lib in librerie_installate) {
  tryCatch({
    suppressPackageStartupMessages(library(lib, character.only = TRUE))
    cat(sprintf("  ✓ %s caricato\n", lib))
  }, error = function(e) {
    errori_caricamento <- c(errori_caricamento, lib)
    cat(sprintf("  ✗ %s: errore di caricamento\n", lib))
  })
}

if (length(errori_caricamento) == 0) {
  cat("\n  ✓ Tutte le librerie caricate con successo!\n\n")
} else {
  cat("\n  ⚠ Alcune librerie non sono state caricate correttamente\n\n")
}


# TEST 4: DIRECTORY E FILE =====================================================
cat("TEST 4: Struttura directory\n")
cat("--------------------------------------------------------------------------------\n")

# Verifica file principali
file_richiesti <- c(
  "did_analisi_russia_ucraina_agroalimentare.R",
  "genera_dati_esempio.R",
  "README_ANALISI_DID.md",
  "GUIDA_RAPIDA.md"
)

for (file in file_richiesti) {
  if (file.exists(file)) {
    cat(sprintf("  ✓ %s\n", file))
  } else {
    cat(sprintf("  ✗ %s (MANCANTE)\n", file))
  }
}

cat("\n")


# TEST 5: CREAZIONE DIRECTORY OUTPUT ===========================================
cat("TEST 5: Creazione directory output\n")
cat("--------------------------------------------------------------------------------\n")

dirs_necessarie <- c("output", "output/tabelle", "output/grafici", "output/dati_preparati", "dati")

for (dir in dirs_necessarie) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
    cat(sprintf("  ✓ %s creata\n", dir))
  } else {
    cat(sprintf("  ✓ %s già esistente\n", dir))
  }
}

cat("\n")


# TEST 6: CAPACITÀ DI SCRITTURA ================================================
cat("TEST 6: Test scrittura file\n")
cat("--------------------------------------------------------------------------------\n")

tryCatch({
  # Test scrittura CSV
  test_df <- data.frame(x = 1:10, y = rnorm(10))
  write.csv(test_df, "output/test_write.csv", row.names = FALSE)
  cat("  ✓ Scrittura CSV OK\n")
  file.remove("output/test_write.csv")
  
  # Test scrittura RDS
  saveRDS(test_df, "output/test_write.rds")
  cat("  ✓ Scrittura RDS OK\n")
  file.remove("output/test_write.rds")
  
  # Test scrittura grafico PNG
  png("output/test_plot.png", width = 800, height = 600)
  plot(1:10, rnorm(10), main = "Test plot")
  dev.off()
  cat("  ✓ Creazione grafico PNG OK\n")
  file.remove("output/test_plot.png")
  
  cat("\n  ✓ Tutti i test di scrittura superati!\n\n")
  
}, error = function(e) {
  cat(sprintf("  ✗ Errore scrittura: %s\n\n", e$message))
})


# TEST 7: MEMORIA DISPONIBILE ==================================================
cat("TEST 7: Memoria disponibile\n")
cat("--------------------------------------------------------------------------------\n")

memoria_mb <- memory.limit()
if (is.finite(memoria_mb)) {
  cat(sprintf("  ℹ Limite memoria: %.0f MB\n", memoria_mb))
} else {
  cat("  ℹ Limite memoria: illimitato (sistema Unix/Linux)\n")
}

# Memoria attualmente usata
memoria_usata <- pryr::mem_used() / 1024^2  # Converti in MB
if (require(pryr, quietly = TRUE)) {
  cat(sprintf("  ℹ Memoria in uso: %.0f MB\n", memoria_usata))
}

cat("\n")


# TEST 8: TEST FUNZIONALITÀ BASE ===============================================
cat("TEST 8: Test funzionalità R base\n")
cat("--------------------------------------------------------------------------------\n")

tryCatch({
  # Test operazioni base
  x <- rnorm(1000)
  y <- x + rnorm(1000, 0, 0.5)
  modelo <- lm(y ~ x)
  
  cat("  ✓ Operazioni numeriche OK\n")
  cat("  ✓ Regressione lineare OK\n")
  
  # Test dplyr
  df_test <- data.frame(gruppo = rep(c("A", "B"), each = 50),
                        valore = rnorm(100))
  df_test %>%
    group_by(gruppo) %>%
    summarise(media = mean(valore)) -> risultato_test
  
  cat("  ✓ Manipolazione dati (dplyr) OK\n")
  
  # Test ggplot2
  p <- ggplot(df_test, aes(x = gruppo, y = valore)) +
    geom_boxplot()
  
  cat("  ✓ Creazione grafici (ggplot2) OK\n\n")
  
}, error = function(e) {
  cat(sprintf("  ✗ Errore test funzionalità: %s\n\n", e$message))
})


# RIEPILOGO FINALE =============================================================
cat("================================================================================\n")
cat("  RIEPILOGO TEST\n")
cat("================================================================================\n\n")

if (length(librerie_mancanti) == 0 && length(errori_caricamento) == 0) {
  cat("✅ TUTTO OK! L'ambiente è configurato correttamente.\n\n")
  cat("Prossimi passi:\n")
  cat("  1. Eseguire 'source(\"genera_dati_esempio.R\")' per creare dati di test\n")
  cat("  2. Eseguire l'analisi DiD con i dati simulati\n")
  cat("  3. Sostituire con dati reali AIDA quando disponibili\n\n")
  cat("Per iniziare:\n")
  cat("  source('genera_dati_esempio.R')\n")
  cat("  source('did_analisi_russia_ucraina_agroalimentare.R')\n")
  cat("  risultati <- esegui_analisi_completa('dati/database_aida_simulato.xlsx')\n\n")
} else {
  cat("⚠️ ATTENZIONE: Alcuni test non sono stati superati.\n\n")
  cat("Problemi rilevati:\n")
  if (length(librerie_mancanti) > 0) {
    cat(sprintf("  • %d librerie mancanti\n", length(librerie_mancanti)))
  }
  if (length(errori_caricamento) > 0) {
    cat(sprintf("  • %d librerie con errori di caricamento\n", length(errori_caricamento)))
  }
  cat("\nInstallare le librerie mancanti prima di procedere.\n\n")
}

cat("================================================================================\n\n")

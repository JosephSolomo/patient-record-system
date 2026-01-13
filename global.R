# ==============================================================================
# global.R
# ==============================================================================

# --- EMERGENCY PACKAGE CHECK (For Render/Leaflet Loop) ---
if (!require("leaflet")) {
  install.packages("leaflet", repos="https://cran.rstudio.com/")
  library(leaflet)
}

# --- Standard Library Loading ---
library(shiny)
library(RPostgres)
library(DBI)
library(DT)
library(shinyjs)
library(dplyr)
library(plotly)
library(tidyr)

# --- IMPORTANT: Sourcing has been removed! ---
# Shiny 1.5+ automatically sources all files in the R/ folder.
# DO NOT manually source db_connect.R, db_queries.R, etc. here.

# --- 4-Digit Alphanumeric ID Helpers ---
format_custom_id <- function(id_vec) {
  if (length(id_vec) == 0) return(id_vec)
  numeric_ids <- as.numeric(id_vec)
  num_part <- sprintf("%04d", numeric_ids)
  letter_part <- LETTERS[((numeric_ids - 1) %% 26) + 1]
  return(paste0(num_part, letter_part))
}

clean_custom_id <- function(custom_id) {
  if (is.null(custom_id) || length(custom_id) == 0 || is.na(custom_id) || custom_id == "") {
    return(NULL)
  }
  as.numeric(gsub("[A-Z]", "", custom_id))
}

# --- Tagapo Subdivision/Compound Lookup (Top 30) ---
tagapo_locations <- data.frame(
  location_name = c(
    "Alinsod Compound", "Amihan Subdivision", "Anros Subdivision", "Bagong Sta. Rosa Village",
    "Buena Rosa 10", "Cataquiz Homes", "Celina Homes", "CRC Homes", "Don Pablo Subdivision",
    "Doña Rosina Compound", "F & F Subdivision", "Fairfield Subdivision", "Farmview Subdivision",
    "Florenceville Subdivision", "Garcia Subdivision", "Golden Meadows Phase", "Gruenville Subdivision",
    "Howard Village", "Ilem Homes", "Juan Encina Compound", "J & B Village", "Labrador Subdivision",
    "Limpo Subdivision", "Mercado Compound", "Manila Doctors’ Village", "Marco Polo Subdivision",
    "Metrogate Subdivision Phase", "Oval Subdivision", "Perlas Subdivision", "Progressive Village"
  ),
  lat = c(14.3200, 14.3180, 14.3195, 14.3185, 14.3210, 14.3175, 14.3220, 14.3160, 14.3205, 14.3190,
          14.3170, 14.3215, 14.3155, 14.3140, 14.3130, 14.3300, 14.3225, 14.3235, 14.3200, 14.3182,
          14.3198, 14.3172, 14.3180, 14.3165, 14.3150, 14.3240, 14.3255, 14.3188, 14.3192, 14.3178),
  lng = c(121.1100, 121.1050, 121.1080, 121.0976, 121.1000, 121.1005, 121.1015, 121.1030, 121.1110, 121.1090,
          121.1070, 121.1000, 121.1040, 121.1060, 121.1055, 121.1000, 121.1120, 121.1020, 121.1115, 121.1025,
          121.1045, 121.1012, 121.1065, 121.1085, 121.1035, 121.1050, 121.1075, 121.1105, 121.0990, 121.1018),
  stringsAsFactors = FALSE
)
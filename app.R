# ==============================================================================
# app.R - Orchestration
# ==============================================================================
library(shiny)
library(shinyjs)
library(DT)
library(leaflet)
library(DBI)
library(RPostgres)

# Note: Shiny 1.5+ automatically loads EVERY file in the R/ folder!
# (This includes: 01_db_connect.R, 02_db_queries.R, patient_map.R, etc.)

# 1. Load Main Components
source("global.R")
source("ui/ui_main.R")
source("server/server_main.R")

# 2. Launch
shinyApp(ui, server)
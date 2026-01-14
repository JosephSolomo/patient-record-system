# ==============================================================================
# app.R
# ==============================================================================
library(shiny)
library(shinyjs)
library(DT)
library(leaflet)
library(DBI)
library(RPostgres)
library(dplyr)
library(plotly)
library(tidyr)

# 1. Load Database Logic First (Crucial for get_diagnoses)
source("db/db_connect.R")
source("db/db_queries.R")

# 2. Load Modules Second
source("module/patient_form.R")
source("module/patient_map.R")

# 3. Load Main App Structure
source("global.R")
source("ui/ui_main.R")
source("server/server_main.R")

# 4. Launch
shinyApp(ui, server)
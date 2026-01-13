# ================================
# app.R
# ================================

# Load required libraries
library(shiny)
library(DBI)
library(RPostgres)

source("module/patient_map.R")
source("module/patient_form.R") # Sourcing this as well since it's in your module folder

source("global.R")

source("ui/ui_main.R")
source("server/server_main.R")

shinyApp(ui, server)
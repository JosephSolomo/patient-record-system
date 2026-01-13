# ================================
# app.R
# ================================
library(shiny)
library(DBI)
library(RPostgres)

source("module/patient_map.R", local = TRUE)
source("module/patient_form.R", local = TRUE)

source("global.R", local = TRUE)

source("ui/ui_main.R", local = TRUE)
source("server/server_main.R", local = TRUE)

shinyApp(ui, server)
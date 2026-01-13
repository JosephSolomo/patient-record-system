# ================================
# app.R
# ================================
library(shiny)
library(DBI)
library(RPostgres)

# 1. Load global configuration
# Keep this only if global.R is still in your main root folder
if (file.exists("global.R")) source("global.R")

# 2. Load the main UI and Server components
# These MUST remain because they are in their own folders, not the R/ folder
source("ui/ui_main.R")
source("server/server_main.R")

# 3. Launch the application
shinyApp(ui, server)
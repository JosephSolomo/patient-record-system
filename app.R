# ================================
# app.R
# ================================

source("patient_map.R")
source("global.R")

source("ui/ui_main.R")
source("server/server_main.R")

shinyApp(ui, server)

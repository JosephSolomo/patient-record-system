# ==============================================================================
# module/patient_map.R
# ==============================================================================

# --- MODULE UI ---
patientMapUI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(4, 
             wellPanel(
               style = "height: 800px; overflow-y: auto; background-color: #ffffff; border-left: 5px solid #B71C1C; box-shadow: 2px 2px 10px rgba(0,0,0,0.1);",
               tags$h4("Locator Analytics", style="color: #B71C1C; font-weight: bold; border-bottom: 2px solid #FDECEC; padding-bottom: 10px;"),
               br(),
               uiOutput(ns("diagnosis_selector")),
               hr(),
               uiOutput(ns("analytics_sidebar"))
             )
      ),
      column(8, leafletOutput(ns("purok_map"), height = 800))
    )
  )
}

# --- MODULE SERVER ---
patientMapServer <- function(id, get_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    selected_purok <- reactiveVal(NULL)
    
    # 1. CENTRALIZED FILTERING
    filtered_analytics_data <- reactive({
      df <- get_data()
      if (!is.null(input$diag_select) && input$diag_select != "") {
        df <- df %>% filter(Diagnosis == input$diag_select)
      }
      return(df)
    })
    
    # 2. UI RENDERERS
    output$diagnosis_selector <- renderUI({
      conn <- create_connection()
      # Calls get_diagnoses now located in db_queries.R
      diagnoses_df <- get_diagnoses(conn)
      dbDisconnect(conn)
      
      selectInput(ns("diag_select"), "Filter by Diagnosis:",
                  choices = c("All Diagnoses" = "", diagnoses_df[[1]]))
    })
    
    observeEvent(input$purok_map_marker_click, { 
      selected_purok(input$purok_map_marker_click$id) 
    })
    
    observeEvent(input$reset_selection, { 
      selected_purok(NULL) 
    })
    
    output$analytics_sidebar <- renderUI({
      df <- filtered_analytics_data()
      
      if (is.null(selected_purok())) {
        tagList(
          div(style="text-align: center; padding: 15px; background: #FDECEC; border-radius: 10px; border: 1px solid #B71C1C; margin-bottom: 20px;",
              tags$h2(nrow(df), style="color: #B71C1C; font-weight: 800; margin: 0; font-size: 40px;"),
              tags$span("TOTAL SYSTEM CASES", style="color: #B71C1C; font-weight: bold; text-transform: uppercase; font-size: 11px;")
          ),
          tags$b(icon("map-marker-alt"), " Geographic Distribution (Area)"),
          plotlyOutput(ns("purok_bar"), height = "220px"),
          br(),
          tags$b(icon("user-clock"), " Standard Age Groups"),
          plotlyOutput(ns("age_dist"), height = "250px"),
          br(),
          tags$b(icon("venus-mars"), " Gender Breakdown"),
          plotlyOutput(ns("gender_pie"), height = "200px")
        )
      } else {
        purok_name <- selected_purok()
        filtered_list <- df %>% filter(Area == purok_name)
        tagList(
          div(style="display: flex; justify-content: space-between; align-items: center; background: #FDECEC; padding: 10px; border-radius: 8px;",
              tags$h5(purok_name, style="font-weight: bold; margin: 0; color: #B71C1C;"),
              actionLink(ns("reset_selection"), "Close", icon = icon("times"), style="color: #757575;")
          ),
          hr(),
          tags$b(paste("Total Patients:", nrow(filtered_list))),
          br(), br(),
          renderTable({
            req(nrow(filtered_list) > 0)
            display_df <- filtered_list[, c("Patient Name", "complete_address")]
            colnames(display_df) <- c("Patient Name", "Address")
            display_df
          }, striped = TRUE, hover = TRUE, width = "100%")
        )
      }
    })
    
    # 3. PLOTLY VISUALS
    output$age_dist <- renderPlotly({
      df <- filtered_analytics_data()
      req(nrow(df) > 0)
      df$Birthday <- as.Date(df$Birthday)
      df$Age <- as.numeric(difftime(Sys.Date(), df$Birthday, units = "weeks")) / 52.25
      
      df <- df %>% mutate(AgeGroup = case_when(
        Age <= 4  ~ "0-4", 
        Age <= 9  ~ "5-9", 
        Age <= 19 ~ "10-19",
        Age <= 29 ~ "20-29", 
        Age <= 59 ~ "30-59", 
        Age >= 60 ~ "60+", 
        TRUE ~ "Unknown"
      ))
      
      std_levels <- c("0-4", "5-9", "10-19", "20-29", "30-59", "60+")
      age_summary <- df %>% 
        group_by(AgeGroup) %>% 
        summarise(Count = n()) %>%
        mutate(AgeGroup = factor(AgeGroup, levels = std_levels)) %>%
        tidyr::complete(AgeGroup, fill = list(Count = 0))
      
      plot_ly(age_summary, x = ~AgeGroup, y = ~Count, type = "bar",
              marker = list(color = '#B71C1C', line = list(color = 'white', width = 1))) %>%
        layout(margin = list(l=30, r=10, t=10, b=40), 
               xaxis = list(title = "Age Categories", tickfont = list(size = 10)), 
               yaxis = list(title = "Cases")) %>%
        config(displayModeBar = FALSE)
    })
    
    output$purok_bar <- renderPlotly({
      df <- filtered_analytics_data()
      req(nrow(df) > 0)
      area_counts <- df %>% group_by(Area) %>% summarise(Count = n()) %>% arrange(Count)
      
      plot_ly(area_counts, x = ~Count, y = ~reorder(Area, Count), type = 'bar', orientation = 'h',
              marker = list(color = '#B71C1C')) %>%
        layout(margin = list(l=120, r=10, t=10, b=30), xaxis = list(title = "Cases"), yaxis = list(title = "")) %>% 
        config(displayModeBar = FALSE)
    })
    
    output$gender_pie <- renderPlotly({
      df <- filtered_analytics_data()
      req(nrow(df) > 0)
      gender_counts <- df %>% group_by(Gender) %>% summarise(Count = n())
      
      plot_ly(gender_counts, labels = ~Gender, values = ~Count, type = 'pie',
              marker = list(colors = c('#B71C1C', '#EF9A9A'), line = list(color = '#FFFFFF', width = 2))) %>%
        layout(margin = list(l=10, r=10, t=10, b=10), showlegend = TRUE) %>%
        config(displayModeBar = FALSE)
    })
    
    # 4. MAP WITH BARANGAY HIGHLIGHT
    output$purok_map <- renderLeaflet({
      map_df <- filtered_analytics_data()
      map_data <- map_df %>% group_by(Area) %>% summarise(count = n()) %>%
        inner_join(tagapo_locations, by = c("Area" = "location_name"))
      
      leaflet(map_data) %>% 
        addProviderTiles(providers$CartoDB.Positron) %>%
        setView(lng = 121.1028, lat = 14.3185, zoom = 15) %>% 
        
        addRectangles(
          lng1 = 121.095, lat1 = 14.310,
          lng2 = 121.115, lat2 = 14.330,
          fillColor = "#B71C1C", fillOpacity = 0.08, 
          color = "#B71C1C", weight = 2, dashArray = "10, 5", group = "Boundary"
        ) %>%
        
        addCircleMarkers(
          lng = ~lng, lat = ~lat, layerId = ~Area,
          radius = ~sqrt(count) * 12, 
          color = "#B71C1C", stroke = TRUE, weight = 2,
          fillColor = "#B71C1C", fillOpacity = 0.6,
          label = ~paste0(Area, ": ", count, " cases")
        ) %>%
        
        addLegend(
          position = "bottomright", colors = "#B71C1C", labels = "Barangay Tagapo Area", opacity = 0.3
        )
    })
  })
}
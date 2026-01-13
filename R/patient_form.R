# --- PATIENT FORM UI ---
patientFormUI <- function(id, is_updating = FALSE) {
  ns <- NS(id)
  tagList(
    useShinyjs(),
    
    # 1. Patient Selection
    if (!is_updating) {
      wellPanel(
        tags$h4("Patient Selection"),
        selectizeInput(ns("select_patient"), "Select Existing Patient", choices = NULL, 
                       options = list(placeholder = 'Search name or ID (Leave blank for New Patient)'))
      )
    },
    
    # 2. Patient Information (Only shows for New Patients)
    div(id = ns("new_patient_fields"),
        wellPanel(style = "background-color: #f9f9f9; border-left: 5px solid #B71C1C;",
                  tags$h4("Patient Information"),
                  fluidRow(
                    column(6, textInput(ns("new_patient_name"), "Full Name", placeholder = "Enter Full Name")),
                    column(6, dateInput(ns("new_dob"), "Date of Birth", value = "2000-01-01"))
                  ),
                  fluidRow(
                    column(6, selectInput(ns("new_gender"), "Gender", choices = c("Male", "Female", "Other"))),
                    column(6, textInput(ns("new_phone"), "Contact Number", placeholder = "09XX-XXX-XXXX"))
                  )
        )
    ),
    
    # 3. Visit Details
    wellPanel(
      tags$h4("Visit Details"),
      fluidRow(
        column(6, dateInput(ns("visit_date"), "Visit Date", value = Sys.Date())),
        
        # Area field: Hidden for existing patients via shinyjs
        div(id = ns("area_div"),
            column(6, selectInput(ns("purok"), "Subdivision/Compound (Area)", 
                                  choices = tagapo_locations$location_name))
        )
      ),
      
      # Detailed Address & Fixed Address Text: Hidden for existing patients
      div(id = ns("address_fields_div"),
          fluidRow(
            column(12, textInput(ns("addr_details"), "House No. / Street / Unit (Detailed Address)", 
                                 placeholder = "e.g., Blk 5 Lot 10 Ph 1 OR House #123"))
          ),
          helpText("Fixed Address: Brgy. Tagapo, Sta. Rosa City, Laguna")
      ),
      
      hr(),
      textAreaInput(ns("complaint"), "Diagnosis/Complaint", rows = 5, placeholder = "Enter detailed diagnosis or complaint")
    )
  )
}

# --- PATIENT FORM SERVER ---
patientFormServer <- function(id, rv_refresh, user_name, id_to_edit = reactive(NULL)) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Dynamic Visibility Logic: Handles New vs. Existing Patient view
    observe({
      # Check if a selection exists in the "Select Existing Patient" dropdown
      is_existing <- !is.null(input$select_patient) && input$select_patient != ""
      is_edit_mode <- !is.null(id_to_edit())
      
      if (is_existing || is_edit_mode) {
        # Hide fields for Old/Existing Patients
        shinyjs::hide("new_patient_fields")
        shinyjs::hide("area_div")
        shinyjs::hide("address_fields_div")
      } else {
        # Show fields for New Patients
        shinyjs::show("new_patient_fields")
        shinyjs::show("area_div")
        shinyjs::show("address_fields_div")
      }
    })
    
    # Save Action Logic
    observeEvent(input$save_visit_all, {
      # Validation
      if (input$complaint == "") {
        showNotification("Diagnosis/Complaint is required.", type = "warning")
        return()
      }
      
      conn <- create_connection(); req(conn); dbBegin(conn)
      
      tryCatch({
        current_id <- id_to_edit()
        
        if (!is.null(current_id)) {
          # EDIT MODE: Use existing data
          p_id <- current_id
          final_purok <- input$purok
          final_addr <- input$addr_details
        } else if (!is.null(input$select_patient) && input$select_patient != "") {
          # EXISTING PATIENT: Fetch retained address from DB
          p_id <- as.integer(input$select_patient)
          addr_data <- get_latest_patient_address(conn, p_id)
          final_purok <- addr_data$purok_or_zone
          final_addr <- addr_data$complete_address
        } else {
          # NEW PATIENT: Use form inputs
          if (input$new_patient_name == "") stop("New patient name is required.")
          p_id <- add_new_patient(conn, input$new_patient_name, as.character(input$new_dob), input$new_gender, input$new_phone)
          final_purok <- input$purok
          final_addr <- input$addr_details
        }
        
        # Ensure full address string is correctly formed for the database
        full_address_string <- if (is.null(final_addr) || final_addr == "") {
          paste(final_purok, "Brgy. Tagapo, Sta. Rosa City, Laguna")
        } else if (grepl("Laguna", final_addr)) {
          final_addr # If it already contains the full string
        } else {
          paste(final_addr, final_purok, "Brgy. Tagapo, Sta. Rosa City, Laguna")
        }
        
        staff_info <- if(is.null(user_name())) "SYSTEM" else user_name()
        
        # Final database entry
        dbExecute(conn, sprintf(
          "INSERT INTO patient_visits (patient_id, visit_date, staff_initials, complaint_or_diagnosis, purok_or_zone, complete_address) VALUES (%s, %s, %s, %s, %s, %s)",
          p_id, 
          dbQuoteString(conn, as.character(input$visit_date)), 
          dbQuoteString(conn, staff_info),
          dbQuoteString(conn, input$complaint), 
          dbQuoteString(conn, final_purok), 
          dbQuoteString(conn, full_address_string)
        ))
        
        dbCommit(conn); removeModal(); rv_refresh$trigger <- rv_refresh$trigger + 1
        showNotification("Record saved successfully.", type = "message")
        
      }, error = function(e) {
        dbRollback(conn); showNotification(paste("Database Error:", e$message), type = "error")
      }, finally = { dbDisconnect(conn) })
    })
  })
}
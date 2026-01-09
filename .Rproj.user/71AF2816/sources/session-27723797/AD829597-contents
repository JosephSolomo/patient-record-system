server <- function(input, output, session) {
  # --- 1. Initialization ---
  vals <- reactiveValues(logged_in = FALSE, show_pass = FALSE)
  rv_refresh <- reactiveValues(trigger = 0)
  current_staff <- reactive({ input$user })
  
  observeEvent(input$toggle_pass_btn, { vals$show_pass <- !vals$show_pass })
  
  # --- 2. Login UI ---
  output$page_content <- renderUI({
    if (!vals$logged_in) {
      div(class = "login-wrapper",
          div(class = "login-card",
              icon("user-md", style = "font-size: 60px; color: #B71C1C; margin-bottom: 20px;"),
              tags$h2("Staff Portal"), tags$p("Patient Record System"), br(),
              div(class = "input-block", textInput("user", "Username:", value = isolate(input$user), placeholder = "Enter username")),
              div(class = "password-container",
                  if (vals$show_pass) { textInput("pass", "Password:", value = isolate(input$pass), placeholder = "Enter password") } 
                  else { passwordInput("pass", "Password:", value = isolate(input$pass), placeholder = "Enter password") },
                  div(class = "password-toggle", actionLink("toggle_pass_btn", icon(if(vals$show_pass) "eye-slash" else "eye")))
              ),
              actionButton("login_btn", "Login", class = "btn-login")
          )
      )
    } else { uiOutput("authenticated_ui") }
  })
  
  observeEvent(input$login_btn, {
    if (is.null(input$user) || input$user == "" || input$pass == "") { 
      showNotification("Enter credentials.", type = "warning"); return() 
    }
    conn <- create_connection(); res <- get_user_by_credentials(conn, input$user, input$pass); dbDisconnect(conn)
    if (nrow(res) > 0) { vals$logged_in <- TRUE } else { showNotification("Invalid login.", type = "error") }
  })
  
  # --- 3. Main Dashboard ---
  output$authenticated_ui <- renderUI({
    req(vals$logged_in)
    tagList(
      tags$style(HTML(".dataTables_wrapper .dataTables_paginate .paginate_button.current { background: #B71C1C !important; color: white !important; }")),
      div(class = "red-header", "Patient Record System",
          div(style = "float: right; font-size: 14px;",
              span(icon("user-md"), paste(" Welcome, ", current_staff())),
              actionButton("logout_btn", "Logout", class = "btn-gray", style = "margin-left:10px;"))),
      navbarPage(title = NULL,
                 tabPanel("Records", icon = icon("database"),
                          wellPanel(style = "background-color: #FDECEC;", 
                                    fluidRow(
                                      column(3, textInput("search_name", label = tags$b("Search Patient Name:"), value = "")),
                                      column(9, div(style = "margin-top: 25px;",
                                                    actionButton("add_visit_btn", "Add Patient Visit", class = "btn-red", icon = icon("user-plus")),
                                                    actionButton("view_archive_btn", "Restore Records", class = "btn-gray", icon = icon("history")),
                                                    shinyjs::disabled(actionButton("view_record_btn", "View Record", class = "btn-gray", icon = icon("id-card"))),
                                                    actionButton("clear_search_btn", "Clear Search", class = "btn-gray", icon = icon("eraser"))))
                                    )),
                          div(class = "data-section", tags$h4("Patient Records"), DTOutput("patient_table"))
                 ),
                 tabPanel("Locator", icon = icon("map-marked-alt"), patientMapUI("map1"))
      )
    )
  })
  
  # --- 4. Data Processing (Unique Patients Only) ---
  get_data <- reactive({
    req(vals$logged_in); rv_refresh$trigger
    conn <- create_connection()
    df <- tryCatch({ get_patients(conn, input$search_name) }, error = function(e) { data.frame() })
    dbDisconnect(conn)
    if (nrow(df) > 0 && "ID" %in% names(df)) { df$ID <- format_custom_id(df$ID) }
    df
  })
  
  output$patient_table <- renderDT(get_data(), selection = "single", options = list(
    pageLength = 10, dom = 'tp', scrollX = TRUE,
    columnDefs = list(list(targets = 10, visible = FALSE)) 
  ))
  
  editing_id <- reactive({
    selected_row <- input$patient_table_rows_selected
    if (length(selected_row) > 0) {
      return(clean_custom_id(get_data()$ID[selected_row]))
    }
    return(NULL)
  })
  
  # --- 5. Portrait View with History & Staff Alignment ---
  observe({
    if (!is.null(input$patient_table_rows_selected)) shinyjs::enable("view_record_btn")
    else shinyjs::disable("view_record_btn")
  })
  
  observeEvent(input$view_record_btn, {
    selected_row <- input$patient_table_rows_selected
    req(selected_row)
    patient <- get_data()[selected_row, ]
    
    conn <- create_connection()
    history_data <- get_patient_history(conn, clean_custom_id(patient$ID))
    dbDisconnect(conn)
    
    showModal(modalDialog(
      title = span(paste("Patient Record -", patient$`Patient Name`), style = "color: #B71C1C; font-weight: bold;"),
      size = "l", easyClose = TRUE,
      footer = tagList(
        actionButton("archive_record_btn", "Archive Record", class = "btn-gray", icon = icon("trash-alt"), style="float: left;"),
        actionButton("edit_record_internal_btn", "Edit Info", class = "btn-red", icon = icon("edit")),
        modalButton("Close")
      ),
      fluidRow(
        column(4, div(style="text-align: center; border: 2px solid #B71C1C; padding: 15px; border-radius: 15px; background: #fff;",
                      icon("user-circle", style="font-size: 80px; color: #B71C1C;"),
                      h4(patient$`Patient Name`, style="margin-top:10px;"), 
                      span(style="font-weight: bold; color: #B71C1C;", paste("ID:", patient$ID)),
                      hr(),
                      tags$b(icon("history"), " Patient History"),
                      div(style="max-height: 300px; overflow-y: auto; margin-top: 10px; font-size: 10px; text-align: left;",
                          if(nrow(history_data) > 0) {
                            renderTable({
                              display_history <- history_data
                              # Fixed Date formatting and integrated staff alignment
                              display_history$Date <- format(as.Date(display_history$Date), "%Y-%m-%d")
                              display_history
                            }, striped = TRUE, hover = TRUE, width = "100%", align = "l")
                          } else {
                            p("No previous records found.", style="color: #757575; padding: 10px;")
                          }
                      )
        )),
        column(8, div(class="well", style="background: white; border-top: 4px solid #B71C1C; min-height: 450px;",
                      h4("Clinical Profile", style="color:#B71C1C; font-weight: bold;"), hr(),
                      fluidRow(
                        column(6, p(strong("Birthday:"), patient$Birthday), p(strong("Gender:"), patient$Gender), p(strong("Contact:"), patient$`Contact No.`)),
                        column(6, p(strong("Most Recent Visit:"), patient$`Visit Date`))
                      ),
                      hr(), p(strong("Complete Address:")), 
                      div(style="padding: 10px; border-left: 3px solid #B71C1C; margin-bottom: 10px;", p(patient$complete_address)),
                      hr(), h5(strong("Latest Diagnosis:")), 
                      div(style="padding: 20px; background: #FDECEC; border-radius: 8px;", p(patient$Diagnosis))))
      )
    ))
  })
  
  # --- 6. Patient Management ---
  observeEvent(input$edit_record_internal_btn, {
    removeModal(); selected_row <- input$patient_table_rows_selected; patient <- get_data()[selected_row, ]
    showModal(modalDialog(
      title = paste("Modify", patient$`Patient Name`), patientFormUI("form_update", is_updating = TRUE), 
      footer = tagList(modalButton("Cancel"), actionButton("form_update-save_visit_all", "Save Changes", class = "btn-red"))
    ))
    updateTextInput(session, "form_update-new_patient_name", value = patient$`Patient Name`)
    updateDateInput(session, "form_update-new_dob", value = as.Date(patient$`Birthday`))
    updateTextInput(session, "form_update-new_phone", value = patient$`Contact No.`)
    updateTextAreaInput(session, "form_update-complaint", value = patient$Diagnosis)
    updateTextInput(session, "form_update-addr_details", value = patient$complete_address)
    updateSelectInput(session, "form_update-purok", selected = patient$Area)
  })
  
  observeEvent(input$archive_record_btn, {
    pid <- clean_custom_id(get_data()$ID[input$patient_table_rows_selected]); conn <- create_connection()
    archive_patient(conn, pid); dbDisconnect(conn); removeModal(); rv_refresh$trigger <- rv_refresh$trigger + 1
  })
  
  observeEvent(input$view_archive_btn, {
    conn <- create_connection(); archived_data <- get_archived_patients(conn); dbDisconnect(conn)
    if (nrow(archived_data) > 0) archived_data$ID <- format_custom_id(archived_data$ID)
    showModal(modalDialog(title = "Archived Patients", DTOutput("archived_table"),
                          footer = tagList(actionButton("restore_action_btn", "Restore Selected", class = "btn-red"), modalButton("Close")), size = "l"))
    output$archived_table <- renderDT(archived_data, selection = "single")
  })
  
  observeEvent(input$restore_action_btn, {
    req(input$archived_table_rows_selected); conn <- create_connection(); archived_data <- get_archived_patients(conn)
    restore_patient(conn, archived_data$ID[input$archived_table_rows_selected]); dbDisconnect(conn)
    removeModal(); rv_refresh$trigger <- rv_refresh$trigger + 1
  })
  
  observeEvent(input$clear_search_btn, { updateTextInput(session, "search_name", value = "") })
  
  observeEvent(input$add_visit_btn, {
    conn <- create_connection(); plist <- get_patient_list(conn); dbDisconnect(conn)
    showModal(modalDialog(
      title = "Add Visit / New Patient", patientFormUI("form1", is_updating = FALSE), size = "m",
      footer = tagList(modalButton("Cancel"), actionButton("form1-save_visit_all", "Save Changes", class = "btn-red"))
    ))
    updateSelectizeInput(session, "form1-select_patient", server = TRUE, choices = setNames(plist$patient_id, plist$patient_name))
  })
  
  patientFormServer("form1", rv_refresh, current_staff, id_to_edit = reactive(NULL))
  patientFormServer("form_update", rv_refresh, current_staff, id_to_edit = editing_id)
  patientMapServer("map1", get_data) 
  observeEvent(input$logout_btn, { session$reload() })
}
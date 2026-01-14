# ==============================================================================
# db/db_queries.R
# ==============================================================================

# --- Locator Helper ---
get_diagnoses <- function(conn) {
  # This function fetches all unique diagnoses for the Locator dropdown
  dbGetQuery(conn, "SELECT DISTINCT complaint_or_diagnosis FROM patient_visits ORDER BY complaint_or_diagnosis ASC")
}

# --- Authentication ---
get_user_by_credentials <- function(conn, username, password) {
  dbGetQuery(conn, "SELECT * FROM users WHERE username = $1 AND password_text = $2",
             params = list(as.character(username), as.character(password)))
}

# --- Patient Records ---
get_patients <- function(conn, search_term = "") {
  if (is.null(search_term) || length(search_term) == 0) search_term <- ""
  
  sql <- "
    SELECT DISTINCT ON (p.patient_id)
           p.patient_id AS \"ID\", 
           p.patient_name AS \"Patient Name\", 
           p.gender AS \"Gender\",
           p.date_of_birth AS \"Birthday\",
           p.phone_number AS \"Contact No.\", 
           v.visit_date AS \"Visit Date\",
           v.complaint_or_diagnosis AS \"Diagnosis\",
           v.purok_or_zone AS \"Area\",
           v.staff_initials AS \"Staff\",
           v.complete_address
    FROM patients p
    INNER JOIN patient_visits v ON p.patient_id = v.patient_id
    WHERE ($1 = '' OR p.patient_name ILIKE $2) AND p.is_active = TRUE
    ORDER BY p.patient_id, v.visit_date DESC"
  
  dbGetQuery(conn, sql, params = list(as.character(search_term), paste0('%', search_term, '%')))
}

# --- Fetch Patient Visit History & Encoders ---
get_patient_history <- function(conn, patient_id) {
  dbGetQuery(conn, "
    SELECT visit_date AS \"Date\", 
           complaint_or_diagnosis AS \"Diagnosis\",
           staff_initials AS \"Encoded By\"
    FROM patient_visits 
    WHERE patient_id = $1 
    ORDER BY visit_date DESC", 
             params = list(as.integer(patient_id)))
}

get_locator_list <- function(conn, diagnosis_filter = "All") {
  sql <- "
    SELECT p.patient_name AS \"Patient Name\", 
           v.complete_address AS \"Address\"
    FROM patients p
    INNER JOIN patient_visits v ON p.patient_id = v.patient_id
    WHERE p.is_active = TRUE"
  
  if (diagnosis_filter != "All") {
    sql <- paste0(sql, " AND v.complaint_or_diagnosis = $1")
    return(dbGetQuery(conn, sql, params = list(as.character(diagnosis_filter))))
  }
  dbGetQuery(conn, sql)
}

get_patient_list <- function(conn) {
  dbGetQuery(conn, "SELECT patient_id, patient_name FROM patients WHERE is_active = TRUE ORDER BY patient_name ASC")
}

add_new_patient <- function(conn, name, dob, gender, phone) {
  res <- dbGetQuery(conn, 
                    "INSERT INTO patients (patient_name, date_of_birth, gender, phone_number, is_active) 
     VALUES ($1, $2, $3, $4, TRUE) RETURNING patient_id",
                    params = list(as.character(name), as.character(dob), as.character(gender), as.character(phone)))
  return(res$patient_id[1])
}

add_patient_visit <- function(conn, patient_id, visit_date, complaint, purok, complete_address, staff) {
  staff_trimmed <- substr(as.character(staff), 1, 10)
  dbExecute(conn, "INSERT INTO patient_visits (patient_id, visit_date, complaint_or_diagnosis, purok_or_zone, complete_address, staff_initials) VALUES ($1, $2, $3, $4, $5, $6)",
            params = list(as.integer(patient_id), as.character(visit_date), as.character(complaint), as.character(purok), as.character(complete_address), staff_trimmed))
}

archive_patient <- function(conn, patient_id) {
  dbExecute(conn, "UPDATE patients SET is_active = FALSE WHERE patient_id = $1", params = list(as.integer(patient_id)))
}

get_archived_patients <- function(conn) {
  dbGetQuery(conn, "SELECT patient_id AS \"ID\", patient_name AS \"Patient Name\", gender AS \"Gender\", date_of_birth AS \"Birthday\", phone_number AS \"Contact No.\" FROM patients WHERE is_active = FALSE ORDER BY patient_name ASC")
}

restore_patient <- function(conn, patient_id) {
  dbExecute(conn, "UPDATE patients SET is_active = TRUE WHERE patient_id = $1", params = list(as.integer(patient_id)))
}
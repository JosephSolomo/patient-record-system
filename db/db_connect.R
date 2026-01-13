library(DBI)
library(RPostgres)

create_connection <- function() {
  is_render <- Sys.getenv("RENDER") != ""
  
  if (is_render) {
    # Cloud Connection (Render)
    dbConnect(
      RPostgres::Postgres(),
      dbname   = Sys.getenv("DB_NAME"),
      host     = Sys.getenv("DB_HOST"),
      port     = as.integer(Sys.getenv("DB_PORT", "5432")), 
      user     = Sys.getenv("DB_USER"),
      password = Sys.getenv("DB_PASS")
    )
  } else {
    # Local Connection
    dbConnect(
      RPostgres::Postgres(),
      dbname   = "healthcenter",
      host     = "localhost",
      port     = 5432,
      user     = "postgres",
      password = "your_local_password" # Change this to your local pgAdmin password
    )
  }
}

tryCatch({
  db_conn <- create_connection()
  if (dbIsValid(db_conn)) {
    message("SUCCESS: Connected to the database.")
  }
}, error = function(e) {
  message("ERROR: Could not establish a database connection: ", e$message)
})
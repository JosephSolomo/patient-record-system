library(DBI)
library(RPostgres)

is_render <- Sys.getenv("RENDER") != ""

if (is_render) {
  db_conn <- dbConnect(
    RPostgres::Postgres(),
    dbname   = Sys.getenv("DB_NAME"),
    host     = Sys.getenv("DB_HOST"),
    port     = as.integer(Sys.getenv("DB_PORT", "5432")), 
    user     = Sys.getenv("DB_USER"),
    password = Sys.getenv("DB_PASS")
  )
} else {
  db_conn <- dbConnect(
    RPostgres::Postgres(),
    dbname   = "healthcenter",
    host     = "localhost",
    port     = 5432,
    user     = "postgres",
    password = "your_local_password" # Change this to your local pgAdmin password
  )
}

if (dbIsValid(db_conn)) {
  message("SUCCESS: Connected to the database.")
} else {
  stop("ERROR: Could not establish a database connection.")
}
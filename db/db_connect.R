library(DBI)
library(RPostgres)

# Check if we are on Render by looking for a Render-specific variable
is_render <- Sys.getenv("RENDER") != ""

if (is_render) {
  # RENDER CONNECTION (Cloud)
  db_conn <- dbConnect(
    RPostgres::Postgres(),
    dbname   = Sys.getenv("DB_NAME"),
    host     = Sys.getenv("DB_HOST"),
    port     = as.integer(Sys.getenv("DB_PORT")),
    user     = Sys.getenv("DB_USER"),
    password = Sys.getenv("DB_PASS")
  )
} else {
  # LOCAL CONNECTION (Your Computer)
  db_conn <- dbConnect(
    RPostgres::Postgres(),
    dbname   = "healthcenter",
    host     = "localhost",
    port     = 5432,
    user     = "postgres",
    password = "your_local_password"
  )
}
library(DBI)
library(RPostgres)

# This will use Render's settings if available, otherwise it uses your local settings
db_conn <- dbConnect(
  RPostgres::Postgres(),
  dbname   = Sys.getenv("DB_NAME", "healthcenter"),
  host     = Sys.getenv("DB_HOST", "localhost"),
  port     = Sys.getenv("DB_PORT", "5432"),
  user     = Sys.getenv("DB_USER", "postgres"),
  password = Sys.getenv("DB_PASS", "your_local_password") 
)
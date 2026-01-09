# ================================
# db/db_connect.R
# ================================

create_connection <- function() {
  tryCatch({
    dbConnect(
      RPostgres::Postgres(),
      host = "localhost",
      port = 5432,
      dbname = "healthcenter",
      user = "postgres",
      password = "j0seph@s0l0m0"
    )
  }, error = function(e) {
    showNotification("Database Connection Failed", type = "error")
    return(NULL)
  })
}

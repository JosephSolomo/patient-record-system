FROM rocker/shiny:latest

# Install system dependencies for PostgreSQL
RUN apt-get update && apt-get install -y libpq-dev libssl-dev && rm -rf /var/lib/apt/lists/*
  
  # Install R packages
  RUN R -e "install.packages(c('shiny', 'shinydashboard', 'RPostgres', 'DBI', 'dplyr', 'tidyr', 'leaflet'), repos='https://cran.rstudio.com/')"

# Copy your app to the container
COPY . /srv/shiny-server/
  
  EXPOSE 3838

CMD ["/usr/bin/shiny-server"]
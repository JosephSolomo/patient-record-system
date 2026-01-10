FROM rocker/shiny:latest

# 1. Install system dependencies for PostgreSQL, Leaflet (Maps), and Plotly
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libssl-dev \
    libxml2-dev \
    libgdal-dev \
    libproj-dev \
    libgeos-dev \
    libudunits2-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Install ALL R packages listed in your global.R
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'RPostgres', 'DBI', 'DT', 'shinyjs', 'leaflet', 'dplyr', 'plotly', 'tidyr'), repos='https://cran.rstudio.com/')"

# 3. Copy your app files to the container
COPY . /srv/shiny-server/

# 4. Ensure the shiny user has permission to read the files
RUN chown -R shiny:shiny /srv/shiny-server/

# 5. Set the port (Render uses the PORT environment variable)
EXPOSE 3838

# 6. Use R to run the app directly to ensure it binds to the correct Port and Host
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/', host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', '3838')))"]
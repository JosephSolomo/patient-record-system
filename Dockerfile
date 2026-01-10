FROM rocker/shiny:latest

# 1. Install Linux system tools FIRST
# These are mandatory for leaflet and RPostgres to install correctly
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libssl-dev \
    libxml2-dev \
    libgdal-dev \
    libproj-dev \
    libgeos-dev \
    libudunits2-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Install R packages SECOND
# We install them in one large command to ensure they all build together
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'RPostgres', 'DBI', 'DT', 'shinyjs', 'leaflet', 'dplyr', 'plotly', 'tidyr'), repos='https://cran.rstudio.com/')"

# 3. Copy your app files
COPY . /srv/shiny-server/

# 4. Set permissions
RUN chown -R shiny:shiny /srv/shiny-server/

EXPOSE 3838

# 5. Dynamic Port Binding for Render
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/', host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', '3838')))"]
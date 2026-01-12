FROM rocker/shiny:latest

# 1. Install ALL Linux spatial, image, and system tools
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libssl-dev \
    libxml2-dev \
    libgdal-dev \
    libproj-dev \
    libgeos-dev \
    libudunits2-dev \
    librsvg2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Install R packages with dependencies
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'RPostgres', 'DBI', 'DT', 'shinyjs', 'leaflet', 'dplyr', 'plotly', 'tidyr'), repos='https://cran.rstudio.com/', dependencies=TRUE)"

# 3. Copy files and set permissions
COPY . /srv/shiny-server/
RUN chown -R shiny:shiny /srv/shiny-server/

# 4. Mandatory Port Binding for Render
EXPOSE 3838
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/', host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', '3838')))"]
FROM rocker/shiny:latest

# 1. Install ALL required Linux system tools
# libssl-dev is the key fix for the 's2' package error
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
    && rm -rf /var/lib/apt/lists/*

# 2. Install R packages
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'RPostgres', 'DBI', 'DT', 'shinyjs', 'leaflet', 'dplyr', 'plotly', 'tidyr'), repos='https://cran.rstudio.com/', dependencies=TRUE)"

# 3. Copy app files and set permissions
COPY . /srv/shiny-server/
RUN chown -R shiny:shiny /srv/shiny-server/

EXPOSE 3838

# 4. Use dynamic port binding for Render
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/', host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', '3838')))"]
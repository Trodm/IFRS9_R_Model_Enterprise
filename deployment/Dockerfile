FROM rocker/r-ver:4.3.3

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    pandoc \
    && rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages(c('plumber','tidyverse','data.table','lubridate','openxlsx','rmarkdown','DT','shiny','jsonlite'), repos='https://cloud.r-project.org')"

WORKDIR /app
COPY . .

EXPOSE 10000

CMD ["R", "-e", "pr <- plumber::plumb('api/plumber.R'); pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT',10000)))"]

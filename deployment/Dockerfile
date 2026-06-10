FROM rocker/r-ver:4.3.3

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev libssl-dev libxml2-dev pandoc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

RUN R -e "install.packages(c('tidyverse','data.table','lubridate','openxlsx','rmarkdown','DT','shiny','plumber','jsonlite'), repos='https://cloud.r-project.org')"

EXPOSE 8000
CMD ["R", "-e", "pr <- plumber::plumb('api/plumber.R'); pr$run(host='0.0.0.0', port=8000)"]

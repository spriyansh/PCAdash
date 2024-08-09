# docker build -t spriyansh29/rshiny_base:shiny_pca_dash .
# Use Rocker's Shiny image
FROM rocker/shiny:4.4

# Update and install necessary OS libraries
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libpng-dev \
    libfontconfig1-dev \
    libcairo2-dev \
    libxt6 \
    libxt-dev \
    libgsl-dev \
    libgeos-dev \
    git \
    cmake \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install required packages from CRAN
RUN Rscript -e 'install.packages("shinybusy", repos = "https://cloud.r-project.org/", dependencies = TRUE, Ncpus = 20, quiet = TRUE)'
RUN Rscript -e 'install.packages("shinycssloaders", repos = "https://cloud.r-project.org/", dependencies = TRUE, Ncpus = 20, quiet = TRUE)'
RUN Rscript -e 'install.packages("shinyjs", repos = "https://cloud.r-project.org/", dependencies = TRUE, Ncpus = 20, quiet = TRUE)'
RUN Rscript -e 'install.packages("shinyBS", repos = "https://cloud.r-project.org/", dependencies = TRUE, Ncpus = 20, quiet = TRUE)'
RUN Rscript -e 'install.packages("bsicons", repos = "https://cloud.r-project.org/", dependencies = TRUE, Ncpus = 20, quiet = TRUE)'
RUN Rscript -e 'install.packages("bslib", repos = "https://cloud.r-project.org/", dependencies = TRUE, Ncpus = 20, quiet = TRUE)'
RUN Rscript -e 'install.packages("styler", repos = "https://cloud.r-project.org/", dependencies = TRUE, Ncpus = 20, quiet = TRUE)'
RUN Rscript -e 'install.packages("plotly", repos = "https://cloud.r-project.org/", dependencies = TRUE, Ncpus = 20, quiet = TRUE)'
RUN Rscript -e 'install.packages("ggplot2", repos = "https://cloud.r-project.org/", dependencies = TRUE, Ncpus = 20, quiet = TRUE)'
RUN Rscript -e "install.packages('devtools', repos = 'https://cloud.r-project.org',dependencies = TRUE, Ncpus = 20, quiet = TRUE)"

# Allow container to use port 3838
EXPOSE 3838

# Copy your custom shiny-server.conf into the container
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

# Change the user to shiny
USER shiny

# Run Shiny Server
CMD ["/usr/bin/shiny-server"]

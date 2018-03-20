FROM ubuntu:xenial
MAINTAINER biodatageeks <team@biodatageeks.ii.pw.edu.pl>

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y r-base libssl-dev libssh2-1-dev libxml2-dev libcurl4-openssl-dev libpq-dev

RUN Rscript -e "install.packages('devtools', repos='http://cran.cnr.berkeley.edu'); devtools::install_github('hadley/testthat')"

RUN Rscript -e "source('https://bioconductor.org/biocLite.R');biocLite('CODEX')"


FROM ubuntu:xenial
MAINTAINER biodatageeks <team@biodatageeks.ii.pw.edu.pl>

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/'
RUN apt-get install -y apt-transport-https

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y r-base libssl-dev libssh2-1-dev libxml2-dev libcurl4-openssl-dev libpq-dev

RUN Rscript -e "source('https://bioconductor.org/biocLite.R');biocLite('CODEX')"

RUN Rscript -e "install.packages('TARGET.QC', repos = 'http://zsibio.ii.pw.edu.pl/nexus/repository/r-all')"

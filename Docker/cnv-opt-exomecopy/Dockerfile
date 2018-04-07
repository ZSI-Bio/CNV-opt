FROM ubuntu:xenial
MAINTAINER biodatageeks <team@biodatageeks.ii.pw.edu.pl>

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/'
RUN apt-get install -y apt-transport-https

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y r-base libssl-dev libssh2-1-dev libxml2-dev libcurl4-openssl-dev libpq-dev wget

RUN Rscript -e "source('https://bioconductor.org/biocLite.R');biocLite('IRanges')"

RUN wget http://bioconductor.org/packages/3.5/bioc/src/contrib/exomeCopy_1.22.0.tar.gz
RUN Rscript -e "install.packages('exomeCopy_1.22.0.tar.gz', repos = NULL, type='source')"

RUN Rscript -e "source('https://bioconductor.org/biocLite.R');biocLite('exomeCopy')"

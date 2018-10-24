FROM biodatageeks/cnv-opt-codex
MAINTAINER biodatageeks <team@biodatageeks.ii.pw.edu.pl>

ARG CACHE_DATE=not_a_specified_date

RUN Rscript -e "install.packages('ExomeDepth', repos = 'http://cran.us.r-project.org')"

RUN Rscript -e "install.packages('REFERENCE.SAMPLE.SET.SELECTOR', repos = 'http://zsibio.ii.pw.edu.pl/nexus/repository/r-all')"

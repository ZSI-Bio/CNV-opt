FROM biodatageeks/cnv-opt-canoes
MAINTAINER biodatageeks <team@biodatageeks.ii.pw.edu.pl>

RUN Rscript -e "source('https://bioconductor.org/biocLite.R');biocLite('CODEX')"

RUN Rscript -e "install.packages('CANOESCOV', repos = 'http://zsibio.ii.pw.edu.pl/nexus/repository/r-all')"

FROM biodatageeks/cnv-opt-exomecopy
MAINTAINER biodatageeks <team@biodatageeks.ii.pw.edu.pl>

RUN Rscript -e "source('https://bioconductor.org/biocLite.R');biocLite('GenomeInfoDb')"
RUN Rscript -e "source('https://bioconductor.org/biocLite.R');biocLite('BSgenome.Hsapiens.UCSC.hg19')"

RUN pwd
RUN pwd
RUN pwd

RUN Rscript -e "install.packages('EXOMECOPYCOV', repos = 'http://zsibio.ii.pw.edu.pl/nexus/repository/r-all')"


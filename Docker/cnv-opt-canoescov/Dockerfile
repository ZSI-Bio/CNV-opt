FROM biodatageeks/cnv-opt-canoes
MAINTAINER biodatageeks <team@biodatageeks.ii.pw.edu.pl>

RUN Rscript -e "source('https://bioconductor.org/biocLite.R');biocLite('IRanges')"
RUN Rscript -e "source('https://bioconductor.org/biocLite.R');biocLite('BSgenome.Hsapiens.UCSC.hg19')"
RUN Rscript -e "source('https://bioconductor.org/biocLite.R');biocLite('Biostrings')"
RUN Rscript -e "source('https://bioconductor.org/biocLite.R');biocLite('Rsamtools')"
RUN Rscript -e "source('https://bioconductor.org/biocLite.R');biocLite('GenomeInfoDb')"
RUN Rscript -e "source('https://bioconductor.org/biocLite.R');biocLite('S4Vectors')"

RUN Rscript -e "install.packages('CANOESCOV', repos = 'http://zsibio.ii.pw.edu.pl/nexus/repository/r-all')"

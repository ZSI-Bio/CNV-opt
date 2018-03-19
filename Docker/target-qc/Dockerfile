FROM biodatageeks/bdg-spark
MAINTAINER biodatageeks <team@biodatageeks.ii.pw.edu.pl>


RUN apt-get update && apt-get install --yes \
				wget \
                 && rm -rf /var/lib/apt/lists/*

RUN wget https://repo1.maven.org/maven2/org/bdgenomics/adam/adam-distribution-spark2_2.11/0.23.0/adam-distribution-spark2_2.11-0.23.0-bin.tar.gz
RUN tar -zxvf adam-distribution-spark2_2.11-0.23.0-bin.tar.gz
RUN mv adam-distribution-spark2_2.11-0.23.0 adam && mv adam /tmp && rm -f adam-distribution-spark2_2.11-0.23.0-bin.tar.gz
ENV PATH="/tmp/adam/bin:${PATH}"







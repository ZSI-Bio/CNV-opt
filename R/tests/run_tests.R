if (length(which(installed.packages()[,1] == "devtools")) == 0){install.packages("devtools",repos="https://cloud.r-project.org/")}
if (length(which(installed.packages()[,1] == "testthat")) == 0){devtools::install_github("hadley/testthat")}
if (length(which(installed.packages()[,1] == "CODEX")) == 0){
    source("http://bioconductor.org/biocLite.R")
    biocLite("CODEX")
}

library(testthat)
source("test_functions_CODEX.R")
capture.output(test_dir(".", reporter="junit"),file="results.xml")

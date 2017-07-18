if (length(which(installed.packages()[,1] == "devtools")) == 0){install.packages("devtools",repos="https://cloud.r-project.org/")}
if (length(which(installed.packages()[,1] == "testthat")) == 0){devtools::install_github("hadley/testthat")}
if (length(which(installed.packages()[,1] == "CODEX")) == 0){
    source("http://bioconductor.org/biocLite.R")
    biocLite("CODEX")
}

setwd('tests/')
devtools::install('../CNVCALLER.RUNNER')

library(testthat)
out <- capture.output(test_dir(".", reporter="junit"))
writeLines(out[grep("<?xml version=", out):length(out)], "results.xml")

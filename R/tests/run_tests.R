if (length(which(installed.packages()[,1] == "devtools")) == 0){install.packages("devtools",repos="https://cloud.r-project.org/")}
if (length(which(installed.packages()[,1] == "testthat")) == 0){devtools::install_github("hadley/testthat")}
if (length(which(installed.packages()[,1] == "CODEX")) == 0){
    source("http://bioconductor.org/biocLite.R")
    biocLite("CODEX")
}
if (length(which(installed.packages()[,1] == "ExomeDepth")) == 0){install.packages("ExomeDepth",repos="https://cloud.r-project.org/")}

if (length(which(installed.packages()[,1] == "CODEXCOV")) > 0){remove.packages("CODEXCOV")}
if (length(which(installed.packages()[,1] == "EXOMEDEPTHCOV")) > 0){remove.packages("EXOMEDEPTHCOV")}
if (length(which(installed.packages()[,1] == "CNVCALLER.RUNNER")) > 0){remove.packages("CNVCALLER.RUNNER")}
if (length(which(installed.packages()[,1] == "CNVCALLER.EVALUATOR")) > 0){remove.packages("CNVCALLER.EVALUATOR")}

setwd('tests/')
devtools::install('../CODEXCOV')
devtools::install('../EXOMEDEPTHCOV')
devtools::install('../CNVCALLER.RUNNER')
devtools::install('../CNVCALLER.EVALUATOR')

library(testthat)
out <- capture.output(test_dir(".", reporter="junit"))
writeLines(out[grep("<?xml version=", out):length(out)], "results.xml")

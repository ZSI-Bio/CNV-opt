if (length(which(installed.packages()[,1] == "devtools")) == 0){install.packages("devtools",repos="https://cloud.r-project.org/")}
if (length(which(installed.packages()[,1] == "testthat")) == 0){devtools::install_github("hadley/testthat")}
if (length(which(installed.packages()[,1] == "CODEX")) == 0){
    source("http://bioconductor.org/biocLite.R")
    biocLite("CODEX")
}
if (length(which(installed.packages()[,1] == "ExomeDepth")) == 0){install.packages("ExomeDepth",repos="https://cloud.r-project.org/")}

if (length(which(installed.packages()[,1] == "TARGET.QC")) > 0){remove.packages("TARGET.QC")}
if (length(which(installed.packages()[,1] == "REFERENCE.SAMPLE.SET.SELECTOR")) > 0){remove.packages("REFERENCE.SAMPLE.SET.SELECTOR")}
if (length(which(installed.packages()[,1] == "CODEXCOV")) > 0){remove.packages("CODEXCOV")}
if (length(which(installed.packages()[,1] == "EXOMEDEPTHCOV")) > 0){remove.packages("EXOMEDEPTHCOV")}
if (length(which(installed.packages()[,1] == "CANOESCOV")) > 0){remove.packages("CANOESCOV")}
if (length(which(installed.packages()[,1] == "CNVCALLER.RUNNER")) > 0){remove.packages("CNVCALLER.RUNNER")}
if (length(which(installed.packages()[,1] == "CNVCALLER.EVALUATOR")) > 0){remove.packages("CNVCALLER.EVALUATOR")}

setwd('tests/')
devtools::install('../TARGET.QC')
devtools::install('../REFERENCE.SAMPLE.SET.SELECTOR')
devtools::install('../CODEXCOV')
devtools::install('../EXOMEDEPTHCOV')
devtools::install('../CANOESCOV')
devtools::install('../CNVCALLER.RUNNER')
devtools::install('../CNVCALLER.EVALUATOR')

# withr package with version greater than 2.0.0 is not compatible with testhat (so far)
if (length(which(installed.packages()[,1] == "withr")) > 0){remove.packages("withr")}
devtools::install_version("withr", version = "2.0.0", repos = "http://cran.us.r-project.org")

library(testthat)
out <- capture.output(test_dir(".", reporter="junit"))
writeLines(out[grep("<?xml version=", out):length(out)], "results.xml")

library(testthat)
source("test_functions_CODEX.R")      # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#source("/home/wiktor/CNV-opt/R/tests/test_functions_CODEX.R")
capture.output(test_dir(".", reporter="junit"),file="results.xml")        # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#capture.output(test_dir("/home/wiktor/CNV-opt/R/tests", reporter="junit"),file="results.xml")
#capture.output(test_dir("/home/wiktor/CNV-opt/R/tests"),file="results.xml")
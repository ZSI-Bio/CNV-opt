library(testthat)
library(CNVCALLER.RUNNER)

context("Testing run_wrapper_CANOESCOV function")

test_that("basic test for run_wrapper_CANOESCOV function, without calls",{
  reference_set_select_method <- "canoes"
  num_of_samples_in_reference_set <- "0"
  cov_table <- read.csv(file="data/cov_table.csv", header=FALSE, sep=",")
  colnames(cov_table) <- c("sample_name", "target_id", "chr", "pos_min", "pos_max", "read_count")
  cov_table[,"sample_name"] <- sapply(cov_table[,"sample_name"], toString)
  cov_table[,"target_id"] <- as.integer(cov_table[,"target_id"])
  cov_table[,"chr"] <- sapply(cov_table[,"chr"], toString)
  cov_table[,"pos_min"] <- as.integer(as.character(cov_table[,"pos_min"]))
  cov_table[,"pos_max"] <- as.integer(as.character(cov_table[,"pos_max"]))
  cov_table[,"read_count"] <- as.numeric(as.character(cov_table[,"read_count"]))
  calls <- run_wrapper_CANOESCOV(reference_set_select_method,
                                 num_of_samples_in_reference_set,
                                 cov_table)
  expect_equal(length(calls), 4)
})


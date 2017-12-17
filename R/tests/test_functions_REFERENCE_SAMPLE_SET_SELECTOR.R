library(testthat)
library(REFERENCE.SAMPLE.SET.SELECTOR)

context("Testing canoes_method function")

test_that("basic test for canoes_method function",{
  investigated_sample <- "sample_1"
  num_refs <- 5
  Y = matrix(as.integer(c(52, 53, 54, 56, 70, 147, 58, 51,
                          25, 22, 39, 31, 27, 217, 17, 27,
                          57, 61, 66, 65, 64, 177, 67, 59, 
                          101, 100, 90, 85, 98, 182, 92, 103, 
                          149, 154, 140, 160, 165, 213, 149, 162, 
                          95, 90, 90, 98, 88, 262, 93, 103, 
                          50, 55, 45, 52, 59, 135, 65, 55, 
                          79, 57, 63, 90, 71, 216, 69, 66)), nrow=8, ncol=8, byrow = TRUE)
  colnames(Y) <- c("sample_1", "sample_2", "sample_3", "sample_4", "sample_5", "sample_6", "sample_7", "sample_8")
  reference_samples <- canoes_method(investigated_sample, 
                                     Y,
                                     num_refs)
  expect_equal(length(reference_samples), 1)
  expect_equal(length(reference_samples$reference_samples), num_refs)
  expect_equal(reference_samples$reference_samples[1], 'sample_8')
  expect_equal(reference_samples$reference_samples[2], 'sample_4')
  expect_equal(reference_samples$reference_samples[3], 'sample_2')
  expect_equal(reference_samples$reference_samples[4], 'sample_3')
  expect_equal(reference_samples$reference_samples[5], 'sample_7')
})


library(testthat)
source("../functions_CODEX.R")  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#source("/home/wiktor/CNV-opt/R/functions_CODEX.R")
context("Testing sum")
test_that("Test sum",{
  expect_equal(calc_func(2,2), 4)
})

test_that("Test sum 2",{
  expect_equal(calc_func(2,2), 5)
})
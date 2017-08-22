library(testthat)
library(CNVCALLER.EVALUATOR)


context("Testing calc_overlap_length function")

test_that("simple overlaping",{
  min1 <- 0
  max1 <- 10
  min2 <- 5
  max2 <- 15
  expect_equal(calc_overlap_length(min1, max1, min2, max2), 5)
})

test_that("without overlaping",{
  min1 <- 0
  max1 <- 10
  min2 <- 15
  max2 <- 25
  expect_equal(calc_overlap_length(min1, max1, min2, max2), 0)
})

test_that("one range contained in another",{
  min1 <- 0
  max1 <- 10
  min2 <- 3
  max2 <- 7
  expect_equal(calc_overlap_length(min1, max1, min2, max2), 4)
})

context("Testing build_intersection_matrix function")

test_that("another sample_name value",{
  calls <- data.frame("sample_name" = character(0), "chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0), "copy_no" = numeric(0));
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=1))
  calls <- rbind(calls, data.frame("sample_name"="sample_2", "chr"="1", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=1))
  calls <- rbind(calls, data.frame("sample_name"="sample_3", "chr"="1", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=1))
  refs <- data.frame("sample_name" = character(0), "chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0), "copy_no" = numeric(0));
  refs <- rbind(refs, data.frame("sample_name"="sample_4", "chr"="1", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=1))
  refs <- rbind(refs, data.frame("sample_name"="sample_5", "chr"="1", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=1))
  intersection_matrix <- build_intersection_matrix(calls, refs)
  expect_equal(nrow(intersection_matrix), 3)
  expect_equal(ncol(intersection_matrix), 2)
  expect_equal(intersection_matrix[1,1], 0.00)
  expect_equal(intersection_matrix[1,2], 0.00)
  expect_equal(intersection_matrix[2,1], 0.00)
  expect_equal(intersection_matrix[2,2], 0.00)
  expect_equal(intersection_matrix[3,1], 0.00)
  expect_equal(intersection_matrix[3,2], 0.00)
})

test_that("another chr value",{
  calls <- data.frame("sample_name" = character(0), "chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0), "copy_no" = numeric(0));
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=1))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="2", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=1))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="3", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=1))
  refs <- data.frame("sample_name" = character(0), "chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0), "copy_no" = numeric(0));
  refs <- rbind(refs, data.frame("sample_name"="sample_1", "chr"="4", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=1))
  refs <- rbind(refs, data.frame("sample_name"="sample_1", "chr"="5", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=1))
  intersection_matrix <- build_intersection_matrix(calls, refs)
  expect_equal(nrow(intersection_matrix), 3)
  expect_equal(ncol(intersection_matrix), 2)
  expect_equal(intersection_matrix[1,1], 0.00)
  expect_equal(intersection_matrix[1,2], 0.00)
  expect_equal(intersection_matrix[2,1], 0.00)
  expect_equal(intersection_matrix[2,2], 0.00)
  expect_equal(intersection_matrix[3,1], 0.00)
  expect_equal(intersection_matrix[3,2], 0.00)
})

test_that("another cnv value",{
  calls <- data.frame("sample_name" = character(0), "chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0), "copy_no" = numeric(0));
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=1))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=1))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=1))
  refs <- data.frame("sample_name" = character(0), "chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0), "copy_no" = numeric(0));
  refs <- rbind(refs, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="dup", "st_bp"=1000, "ed_bp"=2000, "copy_no"=3))
  refs <- rbind(refs, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="dup", "st_bp"=1000, "ed_bp"=2000, "copy_no"=3))
  intersection_matrix <- build_intersection_matrix(calls, refs)
  expect_equal(nrow(intersection_matrix), 3)
  expect_equal(ncol(intersection_matrix), 2)
  expect_equal(intersection_matrix[1,1], 0.00)
  expect_equal(intersection_matrix[1,2], 0.00)
  expect_equal(intersection_matrix[2,1], 0.00)
  expect_equal(intersection_matrix[2,2], 0.00)
  expect_equal(intersection_matrix[3,1], 0.00)
  expect_equal(intersection_matrix[3,2], 0.00)
})

test_that("several intersection",{
  calls <- data.frame("sample_name" = character(0), "chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0), "copy_no" = numeric(0));
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=500, "ed_bp"=1000, "copy_no"=1))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=1))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=1500, "ed_bp"=7500, "copy_no"=1))
  refs <- data.frame("sample_name" = character(0), "chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0), "copy_no" = numeric(0));
  refs <- rbind(refs, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=1))
  refs <- rbind(refs, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=7000, "ed_bp"=8000, "copy_no"=1))
  intersection_matrix <- build_intersection_matrix(calls, refs)
  expect_equal(nrow(intersection_matrix), 3)
  expect_equal(ncol(intersection_matrix), 2)
  expect_equal(intersection_matrix[1,1], 0.00)
  expect_equal(intersection_matrix[1,2], 0.00)
  expect_equal(intersection_matrix[2,1], 100.00)
  expect_equal(intersection_matrix[2,2], 0.00)
  expect_equal(intersection_matrix[3,1], 14.29)
  expect_equal(intersection_matrix[3,2], 14.29)
})

context("Testing filter_intersection_matrix_by_overlap_factor function")

test_that("basic test",{
  intersection_matrix <- data.frame(V1 = numeric(0), V2 = numeric(0));
  intersection_matrix <- rbind(intersection_matrix, data.frame(V1=0.00, V2=1.00))
  intersection_matrix <- rbind(intersection_matrix, data.frame(V1=2.00, V2=3.00))
  intersection_matrix <- rbind(intersection_matrix, data.frame(V1=4.00, V2=5.00))
  min_overlap_factor <- 3.00
  intersection_matrix <- filter_intersection_matrix_by_overlap_factor(intersection_matrix, min_overlap_factor)
  expect_equal(nrow(intersection_matrix), 3)
  expect_equal(ncol(intersection_matrix), 2)
  expect_equal(intersection_matrix[1,1], 0.00)
  expect_equal(intersection_matrix[1,2], 0.00)
  expect_equal(intersection_matrix[2,1], 0.00)
  expect_equal(intersection_matrix[2,2], 3.00)
  expect_equal(intersection_matrix[3,1], 4.00)
  expect_equal(intersection_matrix[3,2], 5.00)
})

context("Testing calc_number_of_different_copy_number_for_cnv function")

test_that("basic test",{
  calls <- data.frame("sample_name" = character(0), "chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0), "copy_no" = numeric(0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=1))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=1))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="dup", "st_bp"=3500, "ed_bp"=4500, "copy_no"=2))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=NA))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=3000, "ed_bp"=4500, "copy_no"=3))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=3500, "ed_bp"=4000, "copy_no"=4))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="2", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=5))
  cnv <- data.frame("chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0))
  cnv <- rbind(cnv, data.frame("chr"="1", "cnv"="del", "st_bp"=3500, "ed_bp"=4500))
  calc_number_of_different_copy_number_for_cnv_result <- calc_number_of_different_copy_number_for_cnv(cnv, calls)
  expect_equal(calc_number_of_different_copy_number_for_cnv_result, 3)
})

context("Testing calc_NA_rate_for_cnv function")

test_that("basic test",{
  calls <- data.frame("sample_name" = character(0), "chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0), "copy_no" = numeric(0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="dup", "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"=NA, "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=3000, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=3500, "ed_bp"=4000, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="2", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_2", "chr"="2", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_2", "chr"="2", "cnv"=NA, "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_2", "chr"="2", "cnv"=NA, "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_3", "chr"="2", "cnv"=NA, "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  cnv <- data.frame("chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0))
  cnv <- rbind(cnv, data.frame("chr"="1", "cnv"="del", "st_bp"=3500, "ed_bp"=4500))
  calc_NA_rate_for_cnv_result <- calc_NA_rate_for_cnv(cnv, calls)
  expect_equal(calc_NA_rate_for_cnv_result, 0.33)
})

context("Testing calc_cnv_frequency function")

test_that("basic test",{
  calls <- data.frame("sample_name" = character(0), "chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0), "copy_no" = numeric(0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=3000, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=3500, "ed_bp"=4000, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="dup", "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="dup", "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="2", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_2", "chr"="2", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_2", "chr"="2", "cnv"=NA, "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_2", "chr"="2", "cnv"=NA, "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_3", "chr"="2", "cnv"=NA, "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  cnv <- data.frame("chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0))
  cnv <- rbind(cnv, data.frame("chr"="1", "cnv"="del", "st_bp"=3500, "ed_bp"=4500))
  calc_cnv_frequency_result <- calc_cnv_frequency(cnv, calls)
  expect_equal(calc_cnv_frequency_result, 0.67)
})

context("Testing calc_confusion_matrix function")

test_that("all values in intersection matrix equal to 1",{
  num_of_original_targets_in_refs  <- 3
  num_of_original_samples_in_refs <- 3
  intersection_matrix <- data.frame(V1 = numeric(0), V2 = numeric(0), V3 = numeric(0));
  intersection_matrix <- rbind(intersection_matrix, data.frame(V1=100.00, V2=100.00, V3=100.00))
  intersection_matrix <- rbind(intersection_matrix, data.frame(V1=100.00, V2=100.00, V3=100.00))
  intersection_matrix <- rbind(intersection_matrix, data.frame(V1=100.00, V2=100.00, V3=100.00))
  confusion_matrix  <- calc_confusion_matrix (intersection_matrix, num_of_original_targets_in_refs , num_of_original_samples_in_refs)
  expect_equal(confusion_matrix$TP, 3)
  expect_equal(confusion_matrix$FP, 0)
  expect_equal(confusion_matrix$FN, 0)
  expect_equal(confusion_matrix$TN, 9)
})

test_that("all values in intersection matrix equal to 0",{
  num_of_original_targets_in_refs  <- 3
  num_of_original_samples_in_refs <- 3
  intersection_matrix <- data.frame(V1 = numeric(0), V2 = numeric(0), V3 = numeric(0));
  intersection_matrix <- rbind(intersection_matrix, data.frame(V1=0.00, V2=0.00, V3=0.00))
  intersection_matrix <- rbind(intersection_matrix, data.frame(V1=0.00, V2=0.00, V3=0.00))
  intersection_matrix <- rbind(intersection_matrix, data.frame(V1=0.00, V2=0.00, V3=0.00))
  confusion_matrix  <- calc_confusion_matrix (intersection_matrix, num_of_original_targets_in_refs , num_of_original_samples_in_refs)
  expect_equal(confusion_matrix$TP, 0)
  expect_equal(confusion_matrix$FP, 3)
  expect_equal(confusion_matrix$FN, 3)
  expect_equal(confusion_matrix$TN, 6)
})

test_that("diagonal intersection matrix",{
  num_of_original_targets_in_refs  <- 3
  num_of_original_samples_in_refs <- 3
  intersection_matrix <- data.frame(V1 = numeric(0), V2 = numeric(0), V3 = numeric(0));
  intersection_matrix <- rbind(intersection_matrix, data.frame(V1=1.00, V2=0.00, V3=0.00))
  intersection_matrix <- rbind(intersection_matrix, data.frame(V1=0.00, V2=1.00, V3=0.00))
  intersection_matrix <- rbind(intersection_matrix, data.frame(V1=0.00, V2=0.00, V3=1.00))
  confusion_matrix  <- calc_confusion_matrix (intersection_matrix, num_of_original_targets_in_refs , num_of_original_samples_in_refs)
  expect_equal(confusion_matrix$TP, 3)
  expect_equal(confusion_matrix$FP, 0)
  expect_equal(confusion_matrix$FN, 0)
  expect_equal(confusion_matrix$TN, 9)
})

test_that("diverse intersection matrix",{
  num_of_original_targets_in_refs  <- 3
  num_of_original_samples_in_refs <- 3
  intersection_matrix <- data.frame(V1 = numeric(0), V2 = numeric(0), V3 = numeric(0));
  intersection_matrix <- rbind(intersection_matrix, data.frame(V1=5.00, V2=0.00, V3=0.00))
  intersection_matrix <- rbind(intersection_matrix, data.frame(V1=0.00, V2=0.00, V3=100.00))
  intersection_matrix <- rbind(intersection_matrix, data.frame(V1=0.00, V2=0.00, V3=0.00))
  confusion_matrix  <- calc_confusion_matrix (intersection_matrix, num_of_original_targets_in_refs , num_of_original_samples_in_refs)
  expect_equal(confusion_matrix$TP, 2)
  expect_equal(confusion_matrix$FP, 1)
  expect_equal(confusion_matrix$FN, 1)
  expect_equal(confusion_matrix$TN, 8)
})

context("Testing calc_quality_statistics function")

test_that("all values equal to 0",{
  TP <- 0
  FP <- 0
  TN <- 0
  FN <- 0
  quality_statistics <- calc_quality_statistics(TP, FP, TN, FN)
  expect_equal(quality_statistics$sensitivity, 0.000)
  expect_equal(quality_statistics$specificity, 0.000)
  expect_equal(quality_statistics$precision, 0.000)
  expect_equal(quality_statistics$accuracy, 0.000)
})

test_that("best confusion matrix - only TP",{
  TP <- 5
  FP <- 0
  TN <- 0
  FN <- 0
  quality_statistics <- calc_quality_statistics(TP, FP, TN, FN)
  expect_equal(quality_statistics$sensitivity, 1.000)
  expect_equal(quality_statistics$specificity, 0.000)
  expect_equal(quality_statistics$precision, 1.000)
  expect_equal(quality_statistics$accuracy, 1.000)
})

test_that("diverse confusion matrix",{
  TP <- 1
  FP <- 2
  TN <- 3
  FN <- 4
  quality_statistics <- calc_quality_statistics(TP, FP, TN, FN)
  expect_equal(quality_statistics$sensitivity, 0.200)
  expect_equal(quality_statistics$specificity, 0.600)
  expect_equal(quality_statistics$precision, 0.333)
  expect_equal(quality_statistics$accuracy, 0.400)
})

context("Testing run_CNVCALLER.EVALUATOR function")

test_that("basic test",{
  calls <- data.frame("sample_name" = character(0), "chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0), "copy_no" = numeric(0));
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=500, "ed_bp"=1500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="dup", "st_bp"=500, "ed_bp"=1500, "copy_no"=3))
  calls <- rbind(calls, data.frame("sample_name"="sample_1", "chr"="2", "cnv"="del", "st_bp"=1500, "ed_bp"=2500, "copy_no"=1))
  calls <- rbind(calls, data.frame("sample_name"="sample_2", "chr"="1", "cnv"="del", "st_bp"=3000, "ed_bp"=4000, "copy_no"=1))
  calls <- rbind(calls, data.frame("sample_name"="sample_2", "chr"="2", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=0))
  calls <- rbind(calls, data.frame("sample_name"="sample_2", "chr"="2", "cnv"="del", "st_bp"=3500, "ed_bp"=4500, "copy_no"=1))
  refs <- data.frame("sample_name" = character(0), "chr" = character(0), "cnv" = character(0), "st_bp" = numeric(0), "ed_bp" = numeric(0), "copy_no" = numeric(0));
  refs <- rbind(refs, data.frame("sample_name"="sample_1", "chr"="1", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=0))
  refs <- rbind(refs, data.frame("sample_name"="sample_1", "chr"="2", "cnv"="del", "st_bp"=2000, "ed_bp"=3000, "copy_no"=1))
  refs <- rbind(refs, data.frame("sample_name"="sample_2", "chr"="1", "cnv"="del", "st_bp"=1000, "ed_bp"=2000, "copy_no"=2))
  refs <- rbind(refs, data.frame("sample_name"="sample_2", "chr"="2", "cnv"="dup", "st_bp"=4000, "ed_bp"=5000, "copy_no"=4))
  parameters <- list(min_overlap_factor=0)
  run_CNVCALLER.EVALUATOR_result <- run_CNVCALLER.EVALUATOR(calls, refs, parameters)
  expect_equal(run_CNVCALLER.EVALUATOR_result$TP, 2)
  expect_equal(run_CNVCALLER.EVALUATOR_result$FP, 4)
  expect_equal(run_CNVCALLER.EVALUATOR_result$TN, 4)
  expect_equal(run_CNVCALLER.EVALUATOR_result$FN, 2)
  expect_equal(run_CNVCALLER.EVALUATOR_result$sensitivity, 0.500)
  expect_equal(run_CNVCALLER.EVALUATOR_result$specificity, 0.500)
  expect_equal(run_CNVCALLER.EVALUATOR_result$precision, 0.333)
  expect_equal(run_CNVCALLER.EVALUATOR_result$accuracy, 0.500)
})




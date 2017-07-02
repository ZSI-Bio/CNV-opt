library(testthat)
#source("../functions_CODEX.R")  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
source("/home/wiktor/CNV-opt/R/functions_CODEX.R")

context("Testing gcmapp1 function")

test_that("the same chromosome value",{
  chr <- "22"
  exom_targets <-data.frame(V1 = numeric(0), V2 = numeric(0), V3 = numeric(0));
  exom_targets <- rbind(exom_targets, data.frame(V1=22, V2=16448825, V3=16449023))
  exom_targets <- rbind(exom_targets, data.frame(V1=22, V2=16449025, V3=16449223))
  exom_targets <- rbind(exom_targets, data.frame(V1=22, V2=16449225, V3=16449423))
  ref <- IRanges(start = exom_targets[,2], end = exom_targets[,3])
  gcmapp1_result <- gcmapp1(chr, ref)
  expect_equal(length(gcmapp1_result$gc), 3)
  expect_equal(round(gcmapp1_result$gc[1], digits=2), 44.72)
  expect_equal(round(gcmapp1_result$gc[2], digits=2), 43.22)
  expect_equal(round(gcmapp1_result$gc[3], digits=2), 46.23)
  expect_equal(length(gcmapp1_result$mapp), 3)
  expect_equal(round(gcmapp1_result$mapp[1], digits=7), 0.5187138)
  expect_equal(round(gcmapp1_result$mapp[2], digits=7), 0.5187138)
  expect_equal(round(gcmapp1_result$mapp[3], digits=7), 0.5187138)
})

test_that("different chromosome value",{
  chr <- "22"
  exom_targets <-data.frame(V1 = numeric(0), V2 = numeric(0), V3 = numeric(0));
  exom_targets <- rbind(exom_targets, data.frame(V1=21, V2=16448825, V3=16449023))
  exom_targets <- rbind(exom_targets, data.frame(V1=21, V2=16449025, V3=16449223))
  exom_targets <- rbind(exom_targets, data.frame(V1=21, V2=16449225, V3=16449423))
  ref <- IRanges(start = exom_targets[,2], end = exom_targets[,3])
  gcmapp1_result <- gcmapp1(chr, ref)
  expect_equal(length(gcmapp1_result$gc), 3)
  expect_equal(round(gcmapp1_result$gc[1], digits=2), 44.72)
  expect_equal(round(gcmapp1_result$gc[2], digits=2), 43.22)
  expect_equal(round(gcmapp1_result$gc[3], digits=2), 46.23)
  expect_equal(length(gcmapp1_result$mapp), 3)
  expect_equal(round(gcmapp1_result$mapp[1], digits=7), 0.5187138)
  expect_equal(round(gcmapp1_result$mapp[2], digits=7), 0.5187138)
  expect_equal(round(gcmapp1_result$mapp[3], digits=7), 0.5187138)
})
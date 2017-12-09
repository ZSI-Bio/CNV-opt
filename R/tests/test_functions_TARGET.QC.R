library(testthat)
library(TARGET.QC)

context("Testing gcmapp1 function")

test_that("the same chromosome value",{
  chr <- "22"
  exom_targets <- data.frame(V1 = numeric(0), V2 = numeric(0), V3 = numeric(0));
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
  exom_targets <- data.frame(V1 = numeric(0), V2 = numeric(0), V3 = numeric(0));
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


context("Testing qcObj1 function")

test_that("test for data drom CODEX demo object",{
  Y <- coverageObjDemo$Y
  sampname <- bambedObjDemo$sampname
  chr <- bambedObjDemo$chr
  ref <- bambedObjDemo$ref
  gc <- gcDemo
  mapp <- mappDemo
  cov_thresh <- c(20, 4000)
  length_thresh <- c(20, 2000)
  mapp_thresh <- 0.9
  gc_thresh <- c(20, 80)
  qcObj1_result <- qcObj1(Y, sampname, chr, ref, mapp, gc, cov_thresh, length_thresh, 
              mapp_thresh, gc_thresh)
  # checks only length of resultant data
  expect_equal(length(qcObj1_result$Y_qc), 46*77)
  expect_equal(length(qcObj1_result$sampname_qc), 46)
  expect_equal(length(qcObj1_result$gc_qc), 77)
  expect_equal(length(qcObj1_result$ref_qc), 77)
})



library(testthat)
source("../functions_CODEX.R")

context("Testing gcmapp1 function")

test_that("the same chromosome value",{
  chr <- "22"
  exom_targets <- data.frame(V1 = numeric(0), V2 = numeric(0), V3 = numeric(0));
  exom_targets <- rbind(exom_targets, data.frame(V1=22, V2=16448825, V3=16449023))
  exom_targets <- rbind(exom_targets, data.frame(V1=22, V2=16449025, V3=16449223))
  exom_targets <- rbind(exom_targets, data.frame(V1=22, V2=16449225, V3=16449423))
  ref <- IRanges(start = exom_targets[,2], end = exom_targets[,3])
  #gcmapp1_result <- gcmapp1(chr, ref)
  #expect_equal(length(gcmapp1_result$gc), 3)
  #expect_equal(round(gcmapp1_result$gc[1], digits=2), 44.72)
  #expect_equal(round(gcmapp1_result$gc[2], digits=2), 43.22)
  #expect_equal(round(gcmapp1_result$gc[3], digits=2), 46.23)
  #expect_equal(length(gcmapp1_result$mapp), 3)
  #expect_equal(round(gcmapp1_result$mapp[1], digits=7), 0.5187138)
  #expect_equal(round(gcmapp1_result$mapp[2], digits=7), 0.5187138)
  #expect_equal(round(gcmapp1_result$mapp[3], digits=7), 0.5187138)
})

test_that("different chromosome value",{
  chr <- "22"
  exom_targets <- data.frame(V1 = numeric(0), V2 = numeric(0), V3 = numeric(0));
  exom_targets <- rbind(exom_targets, data.frame(V1=21, V2=16448825, V3=16449023))
  exom_targets <- rbind(exom_targets, data.frame(V1=21, V2=16449025, V3=16449223))
  exom_targets <- rbind(exom_targets, data.frame(V1=21, V2=16449225, V3=16449423))
  ref <- IRanges(start = exom_targets[,2], end = exom_targets[,3])
  #gcmapp1_result <- gcmapp1(chr, ref)
  #expect_equal(length(gcmapp1_result$gc), 3)
  #expect_equal(round(gcmapp1_result$gc[1], digits=2), 44.72)
  #expect_equal(round(gcmapp1_result$gc[2], digits=2), 43.22)
  #expect_equal(round(gcmapp1_result$gc[3], digits=2), 46.23)
  #expect_equal(length(gcmapp1_result$mapp), 3)
  #expect_equal(round(gcmapp1_result$mapp[1], digits=7), 0.5187138)
  #expect_equal(round(gcmapp1_result$mapp[2], digits=7), 0.5187138)
  #expect_equal(round(gcmapp1_result$mapp[3], digits=7), 0.5187138)
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


context("Testing normObj1 function")

test_that("eight samples from CODEX demo object",{
  Y_qc = matrix(as.integer(c(52, 53, 54, 56, 70, 147, 58, 51,
                             25, 22, 39, 31, 27, 217, 17, 27,
                             57, 61, 66, 65, 64, 177, 67, 59, 
                             101, 100, 90, 85, 98, 182, 92, 103, 
                             149, 154, 140, 160, 165, 213, 149, 162, 
                             95, 90, 90, 98, 88, 262, 93, 103, 
                             50, 55, 45, 52, 59, 135, 65, 55, 
                             79, 57, 63, 90, 71, 216, 69, 66)), nrow=8, ncol=8, byrow = TRUE)
  gc_qc <- c(60.54688, 67.93722, 64.07407, 61.86770, 62.74090, 61.18598, 63.13364, 65.08423)
  normObj1_result <- normObj1(Y_qc, gc_qc, K = 1:5)
  expect_equal(length(normObj1_result$K), 5)
  expect_equal(normObj1_result$K[1], 1)
  expect_equal(normObj1_result$K[2], 2)
  expect_equal(normObj1_result$K[3], 3)
  expect_equal(normObj1_result$K[4], 4)
  expect_equal(normObj1_result$K[5], 5)
  expect_equal(length(normObj1_result$AIC), 5)
  expect_equal(round(normObj1_result$AIC[1], digits=2), 42923.03)
  expect_equal(round(normObj1_result$AIC[2], digits=2), 42892.84)
  expect_equal(round(normObj1_result$AIC[3], digits=2), 42863.64)
  expect_equal(round(normObj1_result$AIC[4], digits=2), 42834.48)
  expect_equal(round(normObj1_result$AIC[5], digits=2), 42802.54)
  expect_equal(length(normObj1_result$BIC), 5)
  expect_equal(round(normObj1_result$BIC[1], digits=2), 42888.49)
  expect_equal(round(normObj1_result$BIC[2], digits=2), 42823.75)
  expect_equal(round(normObj1_result$BIC[3], digits=2), 42760.02)
  expect_equal(round(normObj1_result$BIC[4], digits=2), 42696.31)
  expect_equal(round(normObj1_result$BIC[5], digits=2), 42629.82)
  expect_equal(length(normObj1_result$RSS), 5)
  expect_equal(round(normObj1_result$RSS[1], digits=6), 8.500000)
  expect_equal(round(normObj1_result$RSS[2], digits=6), 6.671875)
  expect_equal(round(normObj1_result$RSS[3], digits=6), 3.765625)
  expect_equal(round(normObj1_result$RSS[4], digits=6), 0.140625)
  expect_equal(round(normObj1_result$RSS[5], digits=6), 0.093750)
})


context("Testing normObj2 function")

test_that("eight samples from CODEX demo object",{
  Y_qc = matrix(as.integer(c(52, 53, 54, 56, 70, 147, 58, 51,
                             25, 22, 39, 31, 27, 217, 17, 27,
                             57, 61, 66, 65, 64, 177, 67, 59, 
                             101, 100, 90, 85, 98, 182, 92, 103, 
                             149, 154, 140, 160, 165, 213, 149, 162, 
                             95, 90, 90, 98, 88, 262, 93, 103, 
                             50, 55, 45, 52, 59, 135, 65, 55, 
                             79, 57, 63, 90, 71, 216, 69, 66)), nrow=8, ncol=8, byrow = TRUE)
  gc_qc <- c(60.54688, 67.93722, 64.07407, 61.86770, 62.74090, 61.18598, 63.13364, 65.08423)
  normObj2_result <- normObj2(Y_qc, gc_qc, K = 1:3, normal_index=seq(1,6,2))
  expect_equal(length(normObj2_result$K), 3)
  expect_equal(normObj2_result$K[1], 1)
  expect_equal(normObj2_result$K[2], 2)
  expect_equal(normObj2_result$K[3], 3)
  expect_equal(length(normObj2_result$AIC), 3)
  expect_equal(round(normObj2_result$AIC[1], digits=2), 42820.50)
  expect_equal(round(normObj2_result$AIC[2], digits=2), 42794.30)
  expect_equal(round(normObj2_result$AIC[3], digits=2), 42772.37)
  expect_equal(length(normObj2_result$BIC), 3)
  expect_equal(round(normObj2_result$BIC[1], digits=2), 42785.96)
  expect_equal(round(normObj2_result$BIC[2], digits=2), 42725.21)
  expect_equal(round(normObj2_result$BIC[3], digits=2), 42668.75)
  expect_equal(length(normObj2_result$RSS), 3)
  expect_equal(round(normObj2_result$RSS[1], digits=4), 454.1719)
  expect_equal(round(normObj2_result$RSS[2], digits=4), 411.5781)
  expect_equal(round(normObj2_result$RSS[3], digits=4), 375.9844)
})


context("Testing segment1 function")

test_that("eight samples from CODEX demo object, last sample modified",{
  Y_qc = matrix(as.integer(c(52, 53, 54, 56, 70, 147, 58, 51,
                             25, 22, 39, 31, 27, 217, 17, 27,
                             57, 61, 66, 65, 64, 177, 67, 59, 
                             101, 100, 90, 85, 98, 182, 92, 103, 
                             149, 154, 140, 160, 165, 213, 149, 162, 
                             95, 90, 90, 98, 88, 262, 93, 103, 
                             50, 55, 45, 52, 59, 135, 65, 55, 
                             179, 57, 63, 90, 71, 216, 69, 66)), nrow=8, ncol=8, byrow = TRUE)
  Yhat_1 = matrix(as.integer(c(51.892922, 55.86624, 55.65993, 52.87505, 54.57585, 125.24848, 51.90346, 58.38174,
                               19.547497, 24.29572, 28.46859, 27.46398, 27.05057, 126.67911, 22.46789, 27.84070,
                               56.861379, 62.60839, 66.12105, 63.79321, 64.79974, 155.60533, 59.21856, 67.87126, 
                               99.200879, 90.40640, 94.56705, 91.21181, 92.71986, 224.69280, 83.60543, 98.65358, 
                               151.835727, 144.76272, 152.65961, 147.53596, 149.78656, 364.11346, 133.79204, 158.39849, 
                               94.697103, 91.50566, 94.47444, 90.49412, 92.64512, 221.64370, 86.66201, 98.86704, 
                               48.511074, 55.18942, 58.55686, 56.10535, 57.67545, 138.43411, 51.81206, 60.55379, 
                               85.932649, 70.96056, 75.31751, 74.18750, 72.81041, 188.15857, 68.57631, 76.63602)), nrow=8, ncol=8, byrow = TRUE)
  Yhat_2 = matrix(as.integer(c(52.086326, 54.61186, 55.58708, 52.61884, 53.93304, 142.68834, 52.10714, 57.83208,
                               21.735404, 23.14808, 30.54607, 27.12759, 24.24138, 206.41319, 20.88523, 27.02854,
                               57.219411, 61.75185, 66.36462, 63.14210, 63.73696, 171.07373, 58.44692, 67.78521, 
                               98.895898, 93.23801, 94.65352, 92.91479, 95.57679, 183.25665, 84.93223, 100.88559, 
                               149.625373, 152.65996, 149.08653, 150.27275, 157.15268, 219.30827, 137.45512, 162.62724, 
                               95.098362, 90.06909, 95.03911, 90.24050, 91.62513, 249.09748, 87.15463, 98.50434, 
                               48.779421, 56.03337, 59.11681, 56.68285, 58.53598, 131.46024, 52.45069, 61.68665, 
                               86.637203, 69.70980, 76.33760, 73.47635, 70.86416, 219.84460, 68.48828, 76.48053)), nrow=8, ncol=8, byrow = TRUE)
  Yhat <- list(Yhat_1, Yhat_2)
  K <- c(1:2)
  optK <- 2
  sampname_qc <- c("sample_1", "sample_2", "sample_3", "sample_4", "sample_5", "sample_6", "sample_7", "sample_8")
  ref_qc  <- data.frame(start = numeric(0), end = numeric(0), width = numeric(0));
  ref_qc <- rbind(ref_qc, data.frame(start=21346453, end=21346708, width=256))
  ref_qc <- rbind(ref_qc, data.frame(start=21348163, end=21348608, width=446))
  ref_qc <- rbind(ref_qc, data.frame(start=21348797, end=21349066, width=270))
  ref_qc <- rbind(ref_qc, data.frame(start=21349109, end=21349365, width=257))
  ref_qc <- rbind(ref_qc, data.frame(start=21349985, end=21350451, width=467))
  ref_qc <- rbind(ref_qc, data.frame(start=21350935, end=21351305, width=371))
  ref_qc <- rbind(ref_qc, data.frame(start=21351471, end=21351687, width=217))
  ref_qc <- rbind(ref_qc, data.frame(start=21354119, end=21354771, width=653))
  ref_qc <- IRanges(start = ref_qc[,1], end = ref_qc[,2], width = ref_qc[,3])
  chr <- 22
  segment1_result <- segment1(Y_qc, Yhat, optK = optK, K = K, sampname_qc,
                              ref_qc, chr, lmax = 200, mode = "integer")
  expect_equal(length(segment1_result), 1)
  expect_equal(segment1_result[1]$finalcall[1], "sample_1")
  expect_equal(segment1_result[1]$finalcall[2], "22")
  expect_equal(segment1_result[1]$finalcall[3], "dup")
  expect_equal(segment1_result[1]$finalcall[4], "21351471")
  expect_equal(segment1_result[1]$finalcall[5], "21354771")
  expect_equal(segment1_result[1]$finalcall[6], "3.301")
  expect_equal(segment1_result[1]$finalcall[7], "7")
  expect_equal(segment1_result[1]$finalcall[8], "8")
  expect_equal(segment1_result[1]$finalcall[9], "229")
  expect_equal(segment1_result[1]$finalcall[10], "134")
  expect_equal(segment1_result[1]$finalcall[11], "3")
  expect_equal(segment1_result[1]$finalcall[12], "25.848")
  expect_equal(segment1_result[1]$finalcall[13], "23.912")
})







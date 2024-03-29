library(testthat)
library(CNVCALLER.RUNNER)

context("Testing run_wrapper_TARGET.QC function")

test_that("basic test for run_wrapper_TARGET.QC function",{
  mapp_thresh <- "0.9"
  cov_thresh_from <- "20"
  cov_thresh_to <- "4000"
  length_thresh_from <- "0"
  length_thresh_to <- "200000"
  gc_thresh_from <- "5"
  gc_thresh_to <- "100"
  cov_table <- as.data.frame(matrix(data=c("NA12044",6,"2",17211,173310,151.636363636364,
                                           "NA11829",4,"2",16712,167190,100,
                                           "NA07051",7,"2",30275,304310,155.929936305732,
                                           "NA07051",1,"2",14642,148820,160.3900414937759,
                                           "NA12044",8,"2",69069,700290,581.723204994797,
                                           "NA12044",9,"2",129133,1292530,30.4462809917355,
                                           "NA12044",10,"2",228233,2283540,223.311475409836,
                                           "NA11829",9,"2",129133,1292530,270.4462809917355,
                                           "NA11829",10,"2",228233,2283540,223.311475409836,
                                           "NA11994",9,"2",129133,1292530,180.4462809917355,
                                           "NA11994",3,"2",15751,159900,500.29357798165138,
                                           "NA11829",5,"2",16834,170740,400.19502074688797,
                                           "NA07051",3,"2",15751,159900,900.75313807531381,
                                           "NA18504",5,"2",16834,170740,110.46887966805,
                                           "NA07051",4,"2",16599,167080,100.72815533980583,
                                           "NA12044",4,"2",16599,166400,100.30952380952381,
                                           "NA11994",2,"2",14943,150630,103.900826446281,
                                           "NA18504",6,"2",17211,173310,81.801652892562,
                                           "NA18504",10,"2",228233,2283540,223.311475409836,
                                           "NA12044",2,"2",14943,150630,76.0661157024793,
                                           "NA07051",8,"2",69069,700290,691.77627471384,
                                           "NA07051",2,"2",14943,150630,170.0826446280992,
                                           "NA18504",1,"2",14642,148820,35.8630705394191,
                                           "NA18504",8,"2",69069,700290,240.60561914672,
                                           "NA12044",3,"2",15751,159900,200.88202247191011,
                                           "NA18504",9,"2",129133,1292530,200.4462809917355,
                                           "NA11829",6,"2",17211,173310,148.95041322314,
                                           "NA18504",2,"2",14943,150630,230.7603305785124,
                                           "NA11829",8,"2",69069,700290,1022.60561914672,
                                           "NA07051",5,"2",16834,170740,76.448132780083,
                                           "NA12044",7,"2",30275,304310,126.821656050955,
                                           "NA11994",4,"2",16599,167130,100.13913043478261,
                                           "NA18504",3,"2",15751,159900,26.0833333333333,
                                           "NA12044",5,"2",16834,170740,400.4070796460177,
                                           "NA18504",7,"2",30275,304310,161.554140127389,
                                           "NA11829",2,"2",14943,150630,22.289256198347,
                                           "NA11994",10,"2",228233,2283540,200.17213114754098,
                                           "NA07051",10,"2",228233,2283540,166.918032786885,
                                           "NA11994",7,"2",30275,304310,172.980891719745,
                                           "NA11994",6,"2",17211,173310,163.595041322314,
                                           "NA11994",8,"2",69069,700290,88.76482830385,
                                           "NA07051",9,"2",129133,1292530,320.4132231404959,
                                           "NA11829",1,"2",14642,148820,51.244813278008,
                                           "NA11829",7,"2",30275,304310,132.828025477707,
                                           "NA11994",5,"2",16834,170740,600.70124481327801,
                                           "NA11994",1,"2",14642,148820,146.879668049793,
                                           "NA07051",6,"2",17211,173310,47.4876033057851,
                                           "NA11829",3,"2",15751,159900,130.2958333333333,
                                           "NA12044",1,"2",14642,148820,111.020746887967,
                                           "NA18504",4,"2",16599,167170,300.58823529411765), nrow=50, ncol=6, byrow=TRUE))
  colnames(cov_table) <- c("sample_name", "target_id", "chr", "pos_min", "pos_max", "read_count")
  cov_table[,"sample_name"] <- sapply(cov_table[,"sample_name"], toString)
  cov_table[,"target_id"] <- as.integer(cov_table[,"target_id"])
  cov_table[,"chr"] <- sapply(cov_table[,"chr"], toString)
  cov_table[,"pos_min"] <- as.integer(as.character(cov_table[,"pos_min"]))
  cov_table[,"pos_max"] <- as.integer(as.character(cov_table[,"pos_max"]))
  cov_table[,"read_count"] <- as.numeric(as.character(cov_table[,"read_count"]))
  cov_table <- run_wrapper_TARGET.QC(mapp_thresh,
                                     cov_thresh_from,
                                     cov_thresh_to,
                                     length_thresh_from,
                                     length_thresh_to,
                                     gc_thresh_from,
                                     gc_thresh_to,
                                     cov_table)
  expect_equal(ncol(cov_table), 6)
  expect_equal(nrow(cov_table), 24)
})

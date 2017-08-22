library(testthat)
if("DNAcopy" %in% (.packages())){detach(package:DNAcopy)} # without it error, because HMZDelFinder load also this library in another version
library(CNVCALLER.EVALUATOR)
if (length(which(installed.packages()[,1] == "RJDBC")) == 0){install.packages("RJDBC",dep=TRUE)}
library(RJDBC)

# make connections to database
if (!file.exists("postgresql-42.1.1.jar")) {
  download.file("http://zsibio.ii.pw.edu.pl/nexus/repository/zsi-bio-raw/common/jdbc/postgresql-42.1.1.jar",destfile="postgresql-42.1.1.jar")
}
drv_psql <- JDBC("org.postgresql.Driver", "./postgresql-42.1.1.jar",identifier.quote="`")
conn_psql <- dbConnect(drv_psql, "jdbc:postgresql://cdh00.ii.pw.edu.pl:15432/cnv-opt", "cnv-opt", "zsibio321")
  
# load only functions from R file
cmds <- parse(system.file("evaluate_cnvcaller.R", package="CNVCALLER.EVALUATOR"))
assign.funs <- sapply(cmds, function(x) {
  if(x[[1]]=="<-") {
    if(x[[3]][[1]]=="function") {
      return(TRUE)
    }
  }
  return(FALSE)
})
eval(cmds[assign.funs])

context("Testing read_parameters function")

test_that("basic test for reading test parameters",{
  parameters <- dbGetQuery(conn_psql, "select * from test_evaluation_parameters")
  expect_equal(nrow(parameters), 1)
  read_parameters_result <- read_parameters("test_evaluation_parameters", parameters[1,"id"], conn_psql)
  expect_equal(length(read_parameters_result), 3)
  expect_equal(read_parameters_result$calls_table, parameters[1,"calls_table"])
  expect_equal(read_parameters_result$refs_table, parameters[1,"refs_table"])
  expect_equal(read_parameters_result$min_overlap_factor, parameters[1,"min_overlap_factor"])
})

context("Testing read_cnv_table function")

 test_that("basic test for reading coverage table from database",{
   calls <- dbGetQuery(conn_psql, "select * from test_evaluation_calls")
   expect_equal(nrow(calls), 2)
   refs <- dbGetQuery(conn_psql, "select * from test_evaluation_refs")
   expect_equal(nrow(refs), 2)
   read_cnv_table_result <- read_cnv_table("test_evaluation_calls", conn_psql)
   expect_equal(read_cnv_table_result[1,"sample_name"], calls[1,"sample_name"])
   expect_equal(read_cnv_table_result[1,"chr"], calls[1,"chr"])
   expect_equal(read_cnv_table_result[1,"cnv"], calls[1,"cnv"])
   expect_equal(read_cnv_table_result[1,"st_bp"], calls[1,"st_bp"])
   expect_equal(read_cnv_table_result[1,"ed_bp"], calls[1,"ed_bp"])
   expect_equal(read_cnv_table_result[1,"copy_no"], calls[1,"copy_no"])
   expect_equal(read_cnv_table_result[2,"sample_name"], calls[2,"sample_name"])
   expect_equal(read_cnv_table_result[2,"chr"], calls[2,"chr"])
   expect_equal(read_cnv_table_result[2,"cnv"], calls[2,"cnv"])
   expect_equal(read_cnv_table_result[2,"st_bp"], calls[2,"st_bp"])
   expect_equal(read_cnv_table_result[2,"ed_bp"], calls[2,"ed_bp"])
   expect_equal(read_cnv_table_result[2,"copy_no"], calls[2,"copy_no"])
   read_cnv_table_result <- read_cnv_table("test_evaluation_refs", conn_psql)
   expect_equal(read_cnv_table_result[1,"sample_name"], refs[1,"sample_name"])
   expect_equal(read_cnv_table_result[1,"chr"], refs[1,"chr"])
   expect_equal(read_cnv_table_result[1,"cnv"], refs[1,"cnv"])
   expect_equal(read_cnv_table_result[1,"st_bp"], refs[1,"st_bp"])
   expect_equal(read_cnv_table_result[1,"ed_bp"], refs[1,"ed_bp"])
   expect_equal(read_cnv_table_result[1,"copy_no"], refs[1,"copy_no"])
   expect_equal(read_cnv_table_result[2,"sample_name"], refs[2,"sample_name"])
   expect_equal(read_cnv_table_result[2,"chr"], refs[2,"chr"])
   expect_equal(read_cnv_table_result[2,"cnv"], refs[2,"cnv"])
   expect_equal(read_cnv_table_result[2,"st_bp"], refs[2,"st_bp"])
   expect_equal(read_cnv_table_result[2,"ed_bp"], refs[2,"ed_bp"])
   expect_equal(read_cnv_table_result[2,"copy_no"], refs[2,"copy_no"])
 })

context("Testing run_evaluator function")

test_that("basic test for run_evaluator function",{
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
  run_evaluator_result <- run_evaluator(calls, refs, parameters)
  expect_equal(run_evaluator_result$TP, 2)
  expect_equal(run_evaluator_result$FP, 4)
  expect_equal(run_evaluator_result$TN, 4)
  expect_equal(run_evaluator_result$FN, 2)
  expect_equal(run_evaluator_result$sensitivity, 0.500)
  expect_equal(run_evaluator_result$specificity, 0.500)
  expect_equal(run_evaluator_result$precision, 0.333)
  expect_equal(run_evaluator_result$accuracy, 0.500)
})

context("Testing save_statistics function")

test_that("basic test for saving statistics to database",{
  dbSendUpdate(conn_psql, "delete from test_evaluation_statistics where accuracy > 2.0")
  statistics <- list(TP=1000, TN=2000, FP=3000, FN=4000, sensitivity=1.0, specificity=2.0, precision=3.0, accuracy=4.0)
  parameters_id <- 1
  save_statistics(statistics, "test_evaluation_statistics", parameters_id, conn_psql)
  saved_statistics <- dbGetQuery(conn_psql, "select * from test_evaluation_statistics where accuracy > 2.0")
  expect_equal(nrow(saved_statistics), 1)
  expect_equal(saved_statistics[1,"parameters_id"], parameters_id)
  expect_equal(saved_statistics[1,"tp"], statistics$TP)
  expect_equal(saved_statistics[1,"tn"], statistics$TN)
  expect_equal(saved_statistics[1,"fp"], statistics$FP)
  expect_equal(saved_statistics[1,"fn"], statistics$FN)
  expect_equal(saved_statistics[1,"sensitivity"], statistics$sensitivity)
  expect_equal(saved_statistics[1,"specificity"], statistics$specificity)
  expect_equal(saved_statistics[1,"precision"], statistics$precision)
  expect_equal(saved_statistics[1,"accuracy"], statistics$accuracy)
  dbSendUpdate(conn_psql, "delete from test_evaluation_statistics where accuracy > 2.0")
})

dbDisconnect(conn_psql)
dbUnloadDriver(drv_psql)

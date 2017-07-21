library(testthat)
detach(package:DNAcopy) # without it error, because HMZDelFinder load also this library in another version
library(CNVCALLER.RUNNER)
if (length(which(installed.packages()[,1] == "RJDBC")) == 0){install.packages("RJDBC",dep=TRUE)}
library(RJDBC)

# make connections to database
if (!file.exists("postgresql-42.1.1.jar")) {
  download.file("http://zsibio.ii.pw.edu.pl:50007/repository/zsi-bio-raw/common/jdbc/postgresql-42.1.1.jar",destfile="postgresql-42.1.1.jar")
}
drv_psql <- JDBC("org.postgresql.Driver", "./postgresql-42.1.1.jar",identifier.quote="`")
conn_psql <- dbConnect(drv_psql, "jdbc:postgresql://cdh00.ii.pw.edu.pl:15432/cnv-opt", "cnv-opt", "zsibio321")


# load only functions from R file
cmds <- parse(system.file("run_cnvcaller.R", package="CNVCALLER.RUNNER"))
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
  parameters <- dbGetQuery(conn_psql, "select * from test_parameters")
  expect_equal(nrow(parameters), 20)
  read_parameters_result <- read_parameters("test_parameters", parameters[1,"id"], conn_psql)
  expect_equal(length(read_parameters_result), 14)
  expect_equal(read_parameters_result$caller, parameters[1,"caller"])
  expect_equal(read_parameters_result$cov_table, parameters[1,"cov_table"])
  expect_equal(read_parameters_result$mapp_thresh, parameters[1,"mapp_thresh"])
  expect_equal(read_parameters_result$cov_thresh_from, parameters[1,"cov_thresh_from"])
  expect_equal(read_parameters_result$cov_thresh_to, parameters[1,"cov_thresh_to"])
  expect_equal(read_parameters_result$length_thresh_from, parameters[1,"length_thresh_from"])
  expect_equal(read_parameters_result$length_thresh_to, parameters[1,"length_thresh_to"])
  expect_equal(read_parameters_result$gc_thresh_from, parameters[1,"gc_thresh_from"])
  expect_equal(read_parameters_result$gc_thresh_to, parameters[1,"gc_thresh_to"])
  expect_equal(read_parameters_result$K_from, parameters[1,"k_from"])
  expect_equal(read_parameters_result$K_to, parameters[1,"k_to"])
  expect_equal(read_parameters_result$lmax, parameters[1,"lmax"])
  expect_equal(read_parameters_result$chr, parameters[1,"chr"])
})

context("Testing read_coverage_table function")

# test_that("basic test for reading coverage table from database",{
#   coverage_table <- dbGetQuery(conn_hive, "select * from test_coverage")
#   expect_equal(nrow(coverage_table), 2)
#   expect_equal(coverage_table[1,"chr"] != coverage_table[2,"chr"], TRUE)
#   read_coverage_table_result <- read_coverage_table("test_coverage", conn_hive, coverage_table[1,"chr"])
#   expect_equal(read_coverage_table_result[1,"sample_name"], coverage_table[1,"sample_name"])
#   expect_equal(read_coverage_table_result[1,"target_id"], coverage_table[1,"target_id"])
#   expect_equal(read_coverage_table_result[1,"chr"], coverage_table[1,"chr"])
#   expect_equal(read_coverage_table_result[1,"pos_min"], coverage_table[1,"pos_min"])
#   expect_equal(read_coverage_table_result[1,"pos_max"], coverage_table[1,"pos_max"])
#   expect_equal(read_coverage_table_result[1,"cov_avg"], coverage_table[1,"cov_avg"])
#   read_coverage_table_result <- read_coverage_table("test_coverage", conn_hive, coverage_table[2,"chr"])
#   expect_equal(read_coverage_table_result[1,"sample_name"], coverage_table[2,"sample_name"])
#   expect_equal(read_coverage_table_result[1,"target_id"], coverage_table[2,"target_id"])
#   expect_equal(read_coverage_table_result[1,"chr"], coverage_table[2,"chr"], "2")
#   expect_equal(read_coverage_table_result[1,"pos_min"], coverage_table[2,"pos_min"])
#   expect_equal(read_coverage_table_result[1,"pos_max"], coverage_table[2,"pos_max"])
#   expect_equal(read_coverage_table_result[1,"cov_avg"], coverage_table[2,"cov_avg"])
# })

context("Testing run_caller function")

test_that("basic test for run_caller function, without calls",{
  parameters <- list(caller="codex",
                     mapp_thresh="0.9",
                     cov_thresh_from="20",
                     cov_thresh_to="4000",
                     length_thresh_from="0",
                     length_thresh_to="200000",
                     gc_thresh_from="5",
                     gc_thresh_to="100",
                     K_from="1",
                     K_to="3",
                     lmax="200")
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
  colnames(cov_table) <- c("sample_name", "target_id", "chr", "pos_min", "pos_max", "cov_avg")
  cov_table[,"sample_name"] <- sapply(cov_table[,"sample_name"], toString)
  cov_table[,"target_id"] <- as.integer(cov_table[,"target_id"])
  cov_table[,"chr"] <- sapply(cov_table[,"chr"], toString)
  cov_table[,"pos_min"] <- as.integer(as.character(cov_table[,"pos_min"]))
  cov_table[,"pos_max"] <- as.integer(as.character(cov_table[,"pos_max"]))
  cov_table[,"cov_avg"] <- as.numeric(as.character(cov_table[,"cov_avg"]))
  calls <- run_caller(parameters, cov_table)
  expect_equal(length(calls), 0)
})


context("Testing save_calls function")

test_that("basic test for saving calls to database",{
  dbSendUpdate(conn_psql, "delete from test_calls where sample_name='cnv_test_sample'")
  calls <- matrix(nrow=2, ncol=13)
  colnames(calls) <- c('sample_name', 'chr', 'cnv', 'st_bp', 'ed_bp', 'length_kb', 'st_exon', 'ed_exon', 'raw_cov', 'norm_cov', 'copy_no', 'lratio', 'mbic')
  calls[1,] <- c('cnv_test_sample', 1, 'dup', 1000, 2000, 3.1, 7, 8, 230, 130, 3, 25.111, 23.222)
  calls[2,] <- c('cnv_test_sample', 2, 'del', 2000, 4000, 6.2, 14, 16, 460, 260, 6, 50.222, 46.444)
  parameters_id <- 1
  scenario_id <- 1
  save_calls(calls, "test_calls", scenario_id, parameters_id, conn_psql)
  saved_calls <- dbGetQuery(conn_psql, "select * from test_calls where sample_name='cnv_test_sample'")
  expect_equal(nrow(saved_calls), 2)
  expect_equal(saved_calls[1,"parameters_id"], parameters_id)
  expect_equal(saved_calls[1,"scenario_id"], scenario_id)
  expect_equal(saved_calls[1,"sample_name"], 'cnv_test_sample')
  expect_equal(saved_calls[1,"chr"], '1')
  expect_equal(saved_calls[1,"cnv"], 'dup')
  expect_equal(saved_calls[1,"st_bp"], '1000')
  expect_equal(saved_calls[1,"ed_bp"], '2000')
  expect_equal(saved_calls[1,"length_kb"], '3.1')
  expect_equal(saved_calls[1,"st_exon"], '7')
  expect_equal(saved_calls[1,"ed_exon"], '8')
  expect_equal(saved_calls[1,"raw_cov"], '230')
  expect_equal(saved_calls[1,"norm_cov"], '130')
  expect_equal(saved_calls[1,"copy_no"], '3')
  expect_equal(saved_calls[1,"lratio"], '25.111')
  expect_equal(saved_calls[1,"mbic"], '23.222')
  expect_equal(saved_calls[2,"parameters_id"], parameters_id)
  expect_equal(saved_calls[2,"sample_name"], 'cnv_test_sample')
  expect_equal(saved_calls[2,"chr"], '2')
  expect_equal(saved_calls[2,"cnv"], 'del')
  expect_equal(saved_calls[2,"st_bp"], '2000')
  expect_equal(saved_calls[2,"ed_bp"], '4000')
  expect_equal(saved_calls[2,"length_kb"], '6.2')
  expect_equal(saved_calls[2,"st_exon"], '14')
  expect_equal(saved_calls[2,"ed_exon"], '16')
  expect_equal(saved_calls[2,"raw_cov"], '460')
  expect_equal(saved_calls[2,"norm_cov"], '260')
  expect_equal(saved_calls[2,"copy_no"], '6')
  expect_equal(saved_calls[2,"lratio"], '50.222')
  expect_equal(saved_calls[2,"mbic"], '46.444')
  dbSendUpdate(conn_psql, "delete from test_calls where sample_name='cnv_test_sample'")
})

dbDisconnect(conn_psql)
dbUnloadDriver(drv_psql)

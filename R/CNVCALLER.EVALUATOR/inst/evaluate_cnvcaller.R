#!/usr/bin/env Rscript
options(java.parameters = "-Xmx1512m")
library(devtools)
library('CNVCALLER.EVALUATOR')
library(optparse)
library(RJDBC)

option_list <- list(
  make_option("--paramsTabName", default="public.evaluation_parameters",
              help="Parameters table. [default %default]"),
  make_option("--resultsTabName", default="public.evaluation_statistics",
              help="Statistics table. [default %default]"),
  make_option("--id", default="1",
              help="Parameters id. [default %default]")
)
opt <- parse_args(OptionParser(option_list=option_list))

read_parameters <- function(tabName, id, conn){
  query <- paste("Select * from ", tabName, " where id = ", id, ";", sep="")
  parameters <- dbGetQuery(conn, query)
  calls_table <- parameters[1,'calls_table']
  refs_table <- parameters[1,'refs_table']
  min_overlap_factor <- parameters[1,'min_overlap_factor']
  return(list(calls_table=calls_table, 
              refs_table=refs_table,
              min_overlap_factor=min_overlap_factor))
}

read_cnv_table <- function(tabName, conn){
  query <- paste("Select * from ", tabName, ";", sep="")
  cnvs <- dbGetQuery(conn, query)
  # map names of columns: from cnvs table to CNVCALLER.EVALUATOR package
  colnames(cnvs)[colnames(cnvs) == 'sample_name'] <- 'sample_name'
  colnames(cnvs)[colnames(cnvs) == 'chr'] <- 'chr'
  colnames(cnvs)[colnames(cnvs) == 'cnv'] <- 'cnv'
  colnames(cnvs)[colnames(cnvs) == 'st_bp'] <- 'st_bp'
  colnames(cnvs)[colnames(cnvs) == 'ed_bp'] <- 'ed_bp'
  colnames(cnvs)[colnames(cnvs) == 'copy_no'] <- 'copy_no'
  cnvs
}

save_statistics <- function(statistics, table_name, parameters_id, conn){
  if (length(statistics) != 0) {
    query <- paste("INSERT INTO ", table_name, " (parameters_id, tp, fp, tn, fn, sensitivity, specificity, precision, accuracy) VALUES (",parameters_id,",'", statistics$TP, "','", statistics$FP, "','", statistics$TN, "','", statistics$FN, "','", statistics$sensitivity, "','", statistics$specificity, "','", statistics$precision, "','", statistics$accuracy, "');", sep="")
    dbSendUpdate(conn, query)
  }
}

run_evaluator <- function(calls, refs, parameters){
  statistics <- run_CNVCALLER.EVALUATOR(calls,
                                        refs,
                                        parameters)
  statistics
}

# connect to psql database
if(str_detect(Sys.getenv('CNV_OPT_PSQL_DRV_URL'), "^http://") || str_detect(Sys.getenv('CNV_OPT_PSQL_DRV_URL'), "^https://")) {
  if (!file.exists(basename(Sys.getenv('CNV_OPT_PSQL_DRV_URL')))) {
    download.file(Sys.getenv('CNV_OPT_PSQL_DRV_URL'), destfile=basename(Sys.getenv('CNV_OPT_PSQL_DRV_URL')))
  }
  drv_psql <- JDBC("org.postgresql.Driver", paste("./", basename(Sys.getenv('CNV_OPT_PSQL_DRV_URL')),sep=""), identifier.quote="`")
} else {
  if (!file.exists(Sys.getenv('CNV_OPT_PSQL_DRV_URL'))) {
    stop("Driver not exists...")
  }
  drv_psql <- JDBC("org.postgresql.Driver", Sys.getenv('CNV_OPT_PSQL_DRV_URL'), identifier.quote="`")
}
conn_psql <- dbConnect(drv_psql, Sys.getenv('CNV_OPT_PSQL_CONN_URL'), Sys.getenv('CNV_OPT_PSQL_USER'), Sys.getenv('CNV_OPT_PSQL_PASSWORD'))

parameters <- read_parameters(opt$paramsTabName, opt$id, conn_psql)
#print(parameters)
calls <- read_cnv_table(parameters$calls_table, conn_psql)
#print(calls[1:5,])
refs <- read_cnv_table(parameters$refs_table, conn_psql)
#print(refs[1:5,])
statistics <- run_evaluator(calls, refs, parameters)
#print(statistics)
save_statistics(statistics, opt$resultsTabName, opt$id, conn_psql)

dbDisconnect(conn_psql)
dbUnloadDriver(drv_psql)

#!/usr/bin/env Rscript
library(devtools)
install('CNVCALLER.RUNNER')      ### zakomentować!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
library('CNVCALLER.RUNNER')
library(optparse)
#install.packages("RJDBC",dep=TRUE)
library(RJDBC)

option_list <- list(
  make_option("--tabName", default="public.test_parameters",
              help="Parameters table. [default %default]"),
  make_option("--id", default="1",
              help="Parameters id. [default %default]")
)
opt <- parse_args(OptionParser(option_list=option_list))

read_parameters <- function(tabName, id, conn){
  query <- paste("Select * from ", tabName, " where id = ", id, ";", sep="")
  parameters <- dbGetQuery(conn, query)
  caller <- parameters[1,'caller']
  cov_table <- parameters[1,'cov_table']
  mapp_thresh <- parameters[1,'mapp_thresh']
  cov_thresh_from <- parameters[1,'cov_thresh_from']
  cov_thresh_to <- parameters[1,'cov_thresh_to']
  length_thresh_from <- parameters[1,'length_thresh_from']
  length_thresh_to <- parameters[1,'length_thresh_to']
  gc_thresh_from <- parameters[1,'gc_thresh_from']
  gc_thresh_to <- parameters[1,'gc_thresh_to']
  K_from <- parameters[1,'k_from']
  K_to <- parameters[1,'k_to']
  lmax <- parameters[1,'lmax']
  return(list(caller=caller, 
              cov_table=cov_table, 
              mapp_thresh=mapp_thresh, 
              cov_thresh_from=cov_thresh_from, 
              cov_thresh_to=cov_thresh_to, 
              length_thresh_from=length_thresh_from, 
              length_thresh_to=length_thresh_to, 
              gc_thresh_from=gc_thresh_from, 
              gc_thresh_to=gc_thresh_to, 
              K_from=K_from, 
              K_to=K_to, 
              lmax=lmax))
}

save_calls <- function(calls, conn){
  if (nrow(calls) != 0) {
    for(i in 1:nrow(calls)) {
      call <- calls[i,]
      query <- paste("INSERT INTO TEST_CALLS (parameters_id, sample_name, chr, cnv, st_bp, ed_bp, length_kb, st_exon, ed_exon, raw_cov, norm_cov, copy_no, lratio, mBIC) VALUES ('", opt$id, "','", call[1], "','", call[2], "','", call[3], "','", call[4], "','", call[5], "','", call[6], "','", call[7], "','", call[8], "','", call[9], "','", call[10], "','", call[11], "','", call[12], "','", call[13], "');", sep="")
      dbSendUpdate(conn, query)
    }
  }
}

read_coverage_table <- function(cov_table, conn){
  #query <- paste("select * from ", cov_table, sep="")
  query <- paste("select * from ", cov_table, " where chr='Y'", sep="")
  ds <- dbGetQuery(conn, query)
  colnames(ds) <- c("sample_name", "target_id", "chr", "pos_min", "pos_max", "cov_avg")
  ds
}

run_caller <- function(parameters, cov_table){
  if (parameters$caller == "codex"){
    calls <- run_wrapper_CODEXCOV(parameters$mapp_thresh,
                                  parameters$cov_thresh_from,
                                  parameters$cov_thresh_to,
                                  parameters$length_thresh_from,
                                  parameters$length_thresh_to,
                                  parameters$gc_thresh_from,
                                  parameters$gc_thresh_to,
                                  parameters$K_from,
                                  parameters$K_to,
                                  parameters$lmax,
                                  cov_table
    )
    calls
  } else if(parameters$caller == "xhmm") {
  }
}

if (!file.exists("zsi-bio-cdh-hive-jdbc_2.11-0.1-assembly.jar")) {
  download.file("http://zsibio.ii.pw.edu.pl:50007/repository/maven-releases/pl/edu/pw/ii/zsibio/zsi-bio-cdh-hive-jdbc_2.11/0.1/zsi-bio-cdh-hive-jdbc_2.11-0.1-assembly.jar",destfile="zsi-bio-cdh-hive-jdbc_2.11-0.1-assembly.jar")
}
drv_hive <- JDBC("com.cloudera.hiveserver2.hive.core.Hive2JDBCDriver", "./zsi-bio-cdh-hive-jdbc_2.11-0.1-assembly.jar",identifier.quote="`")
conn_hive <- dbConnect(drv_hive, "jdbc:hive2://cdh01.ii.pw.edu.pl:10000", "mwiewior", "")

if (!file.exists("postgresql-42.1.1.jar")) {
  download.file("http://zsibio.ii.pw.edu.pl:50007/repository/zsi-bio-raw/common/jdbc/postgresql-42.1.1.jar",destfile="postgresql-42.1.1.jar")
}
drv_psql <- JDBC("org.postgresql.Driver", "./postgresql-42.1.1.jar",identifier.quote="`")
conn_psql <- dbConnect(drv_psql, "jdbc:postgresql://cdh00.ii.pw.edu.pl:15432/cnv-opt", "cnv-opt", "zsibio321")

parameters <- read_parameters(opt$tabName, opt$id, conn_psql)
#print(parameters)
cov_table <- read_coverage_table(parameters$cov_table, conn_hive)
#print(cov_table)
calls <- run_caller(parameters, cov_table)
#print(calls)
save_calls(calls, conn_psql)

dbDisconnect(conn_hive)
dbUnloadDriver(drv_hive)

dbDisconnect(conn_psql)
dbUnloadDriver(drv_psql)

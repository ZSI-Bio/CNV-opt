#!/usr/bin/env Rscript
options(java.parameters = "-Xmx1512m")
library(devtools)
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
  chr <- parameters[1,'chr']
  scenario_id  <- parameters[1,'scenario_id']

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
              lmax=lmax,
              chr=chr,
              scenario_id=scenario_id))
}

save_calls <- function(calls, table_name,scenario_id, parameters_id, conn){
  if (nrow(calls) != 0) {
    for(i in 1:nrow(calls)) {
      call <- calls[i,]
      query <- paste("INSERT INTO ",
      table_name, " (scenario_id, parameters_id, sample_name, chr, cnv, st_bp, ed_bp, length_kb, st_exon, ed_exon, raw_cov, norm_cov, copy_no, lratio, mBIC) VALUES (",scenario_id,",'", parameters_id, "','", call[1], "','", call[2], "','", call[3], "','", call[4], "','", call[5], "','", call[6], "','", call[7], "','", call[8], "','", call[9], "','", call[10], "','", call[11], "','", call[12], "','", call[13], "');", sep="")
      writeLines(query,"query.txt")
        dbSendUpdate(conn, query)

    }
  }
}

read_coverage_table <- function(cov_table, conn,chr){
  query <- paste("select sample_name,target_id,chr,pos_min,pos_max,read_count from ", cov_table," where chr='",chr,"'", sep="")
  print(query)
  ds <- dbGetQuery(conn, query)
  # map names of columns: from coverage table to CODEXCOV package
  colnames(ds)[colnames(ds) == 'sample_name'] <- 'sample_name'
  colnames(ds)[colnames(ds) == 'target_id'] <- 'target_id'
  colnames(ds)[colnames(ds) == 'chr'] <- 'chr'
  colnames(ds)[colnames(ds) == 'pos_min'] <- 'pos_min'
  colnames(ds)[colnames(ds) == 'pos_max'] <- 'pos_max'
  colnames(ds)[colnames(ds) == 'read_count'] <- 'read_count'
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

if (!file.exists("postgresql-42.1.1.jar")) {
  download.file("http://zsibio.ii.pw.edu.pl/nexus/repository/zsi-bio-raw/common/jdbc/postgresql-42.1.1.jar",destfile="postgresql-42.1.1.jar")
}
drv_psql <- JDBC("org.postgresql.Driver", Sys.getenv('CNV_OPT_PSQL_DRV_URL'), identifier.quote="`")
conn_psql <- dbConnect(drv_psql, Sys.getenv('CNV_OPT_PSQL_CONN_URL'), Sys.getenv('CNV_OPT_PSQL_USER'), Sys.getenv('CNV_OPT_PSQL_PASSWORD'))

parameters <- read_parameters(opt$tabName, opt$id, conn_psql)
print(parameters)
cov_table <- read_coverage_table(parameters$cov_table, conn_psql,parameters$chr)
#print(cov_table)
calls <- run_caller(parameters, cov_table)
#print(calls)
save_calls(calls, "TEST_CALLS", parameters$scenario_id ,opt$id, conn_psql)

dbDisconnect(conn_psql)
dbUnloadDriver(drv_psql)

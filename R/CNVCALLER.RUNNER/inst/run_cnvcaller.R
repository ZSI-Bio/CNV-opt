#!/usr/bin/env Rscript
options(java.parameters = "-Xmx1512m")
library(devtools)
library('CNVCALLER.RUNNER')
library(optparse)
library(RJDBC)
if (length(which(installed.packages()[,1] == "stringr")) == 0){install.packages("stringr",repos="https://cloud.r-project.org/")}
library(stringr)

option_list <- list(
  make_option("--paramsTabName", default="public.runner_parameters",
              help="Parameters table. [default %default]"),
  make_option("--resultsTabName", default="public.runner_calls",
              help="Calls table. [default %default]"),
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
  reference_set_select_method <- parameters[1,'reference_set_select_method']
  num_of_samples_in_reference_set <- parameters[1,'num_of_samples_in_reference_set']
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
              reference_set_select_method=reference_set_select_method,
              num_of_samples_in_reference_set=num_of_samples_in_reference_set,
              scenario_id=scenario_id))
}

save_calls <- function(calls, table_name, caller, scenario_id, parameters_id, conn){
  if (nrow(calls) != 0) {
    if (caller == "codex"){
      for(i in 1:nrow(calls)) {
        call <- calls[i,]
        query <- paste("INSERT INTO ", table_name, " (scenario_id, parameters_id, sample_name, chr, cnv, st_bp, ed_bp, st_exon, ed_exon, raw_cov, norm_cov, copy_no, codex_lratio, codex_mBIC, exomedepth_BF) VALUES (",scenario_id,",'", parameters_id, "','", call['sample_name'], "','", call['chr'], "','", call['cnv'], "','", call['st_bp'], "','", call['ed_bp'], "','", call['st_exon'], "','", call['ed_exon'], "','", call['raw_cov'], "','", call['norm_cov'], "','", call['copy_no'], "','", call['codex_lratio'], "','", call['codex_mBIC'], "','0.00');", sep="")
        dbSendUpdate(conn, query)
      }
    } else if (caller == "exomedepth"){
      for(i in 1:nrow(calls)) {
        call <- calls[i,]
        query <- paste("INSERT INTO ", table_name, " (scenario_id, parameters_id, sample_name, chr, cnv, st_bp, ed_bp, st_exon, ed_exon, raw_cov, norm_cov, copy_no, codex_lratio, codex_mBIC, exomedepth_BF) VALUES (",scenario_id,",'", parameters_id, "','", call[1], "','", call['chr'], "','", call['cnv'], "','", call['st_bp'], "','", call['ed_bp'], "','", call['st_exon'], "','", call['ed_exon'], "','", call['raw_cov'], "','", call['norm_cov'], "','", call['copy_no'], "','0.00','0.00','", call['exomedepth_BF'], "');", sep="")
        dbSendUpdate(conn, query)
      }
    } else if (caller == "canoes"){
      for(i in 1:nrow(calls)) {
        call <- calls[i,]
        query <- paste("INSERT INTO ", table_name, " (scenario_id, parameters_id, sample_name, chr, cnv, st_bp, ed_bp, st_exon, ed_exon, raw_cov, norm_cov, copy_no, codex_lratio, codex_mBIC, exomedepth_BF) VALUES (",scenario_id,",'", parameters_id, "','", call['sample_name'], "','", call['chr'], "','", call['cnv'], "','", call['st_bp'], "','", call['ed_bp'], "','", call['st_exon'], "','", call['ed_exon'], "','0','0','", call['copy_no'], "','0.00','0.00','0.00');", sep="")
        #writeLines(query,"query.txt")
        dbSendUpdate(conn, query)
      }
    } else if(caller == "xhmm") {
    }
  }
}

read_coverage_table <- function(cov_table, conn,chr){
  query <- paste("select sample_name,target_id,chr,pos_min,pos_max,read_count from ", cov_table," where chr='",chr,"'", sep="")
  print(query)
  ds <- dbGetQuery(conn, query)
  # map names of columns: from coverage table to CODEXCOV, EXOMEDEPTHCOV and CANOESCOV packages
  colnames(ds)[colnames(ds) == 'sample_name'] <- 'sample_name'
  colnames(ds)[colnames(ds) == 'target_id'] <- 'target_id'
  colnames(ds)[colnames(ds) == 'chr'] <- 'chr'
  colnames(ds)[colnames(ds) == 'pos_min'] <- 'pos_min'
  colnames(ds)[colnames(ds) == 'pos_max'] <- 'pos_max'
  colnames(ds)[colnames(ds) == 'read_count'] <- 'read_count'
  ds
}

target_qc <- function(cov_table, parameters){
  cov_table <- run_wrapper_TARGET.QC(parameters$mapp_thresh,
                                     parameters$cov_thresh_from,
                                     parameters$cov_thresh_to,
                                     parameters$length_thresh_from,
                                     parameters$length_thresh_to,
                                     parameters$gc_thresh_from,
                                     parameters$gc_thresh_to,
                                     cov_table
  )
  cov_table
}

run_caller <- function(parameters, cov_table){
  if (parameters$caller == "codex"){
    calls <- run_wrapper_CODEXCOV(parameters$K_from,
                                  parameters$K_to,
                                  parameters$lmax,
                                  parameters$reference_set_select_method,
                                  parameters$num_of_samples_in_reference_set,
                                  cov_table
    )
    calls
  } else if (parameters$caller == "exomedepth"){
    calls <- run_wrapper_EXOMEDEPTHCOV(parameters$reference_set_select_method,
                                       parameters$num_of_samples_in_reference_set,
                                       cov_table)
    calls
  } else if (parameters$caller == "canoes"){
    calls <- run_wrapper_CANOESCOV(parameters$reference_set_select_method,
                                   parameters$num_of_samples_in_reference_set,
                                   cov_table)
    calls
  } else if(parameters$caller == "xhmm") {
  }
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
cov_table <- read_coverage_table(parameters$cov_table, conn_psql, parameters$chr)
#print(cov_table[1:5,])
cov_table <- target_qc(cov_table, parameters)
#print(cov_table[1:5,])
calls <- run_caller(parameters, cov_table)
#print(calls)
save_calls(calls, opt$resultsTabName, parameters$caller, parameters$scenario_id ,opt$id, conn_psql)

dbDisconnect(conn_psql)
dbUnloadDriver(drv_psql)

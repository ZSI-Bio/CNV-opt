#!/usr/bin/env Rscript
library(devtools)
install('CNVCALLER.RUNNER')      ### zakomentować!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
library('CNVCALLER.RUNNER')
library(optparse)


option_list <- list(
  make_option("--id", default=1,
              help="Id of parameters [default %default]"),
  make_option("--mapp_thresh", default=0.9,
              help="Mapping threshold for quality checking. [default %default]"),
  make_option("--cov_thresh_from", default=20,
              help="Coverage threshold (begin of interval) for quality checking.  [default %default]"),
  make_option("--cov_thresh_to", default=4000,
              help="Coverage threshold (end of interval) for quality checking.  [default %default]"),
  make_option("--length_thresh_from", default=20,
              help="Length threshold (begin of interval) for quality checking.  [default %default]"),
  make_option("--length_thresh_to", default=2000,
              help="Length threshold (end of interval) for quality checking.  [default %default]"),
  make_option("--gc_thresh_from", default=20,
              help="GC threshold (begin of interval) for quality checking.  [default %default]"),
  make_option("--gc_thresh_to", default=80,
              help="GC threshold (end of interval) for quality checking.  [default %default]"),
  make_option("--K_from", default=1,
              help="K value (begin of interval).  [default %default]"),
  make_option("--K_to", default=9,
              help="K value (end of interval).  [default %default]"),
  make_option("--lmax", default=200,
              help="Maximum CNV length in number of exons returned. [default %default]"),
  make_option("--cov_table", default="ds",
              help="Coverage table. [default %default]")
)

opt <- parse_args(OptionParser(option_list=option_list))




library(RJDBC)
#download.file("http://zsibio.ii.pw.edu.pl:50007/repository/maven-releases/pl/edu/pw/ii/zsibio/zsi-bio-cdh-hive-jdbc_2.11/0.1/zsi-bio-cdh-hive-jdbc_2.11-0.1-assembly.jar",destfile="zsi-bio-cdh-hive-jdbc_2.11-0.1-assembly.jar")
drv <- JDBC("com.cloudera.hiveserver2.hive.core.Hive2JDBCDriver", "./zsi-bio-cdh-hive-jdbc_2.11-0.1-assembly.jar",identifier.quote="`")
conn <- dbConnect(drv, "jdbc:hive2://cdh01.ii.pw.edu.pl:10000", "mwiewior", "")
ds <-dbGetQuery(conn, "select * from cnv.coverage_target limit 10")
colnames(ds) <- c("sample_name", "target_id", "chr", "pos_min", "pos_max", "cov_avg")



#calls <- run_wrapper_CODEXCOV(opt$mapp_thresh,
#                              opt$cov_thresh_from,
#                              opt$cov_thresh_to,
#                              opt$length_thresh_from,
#                              opt$length_thresh_to,
#                              opt$gc_thresh_from,
#                              opt$gc_thresh_to,
#                              opt$K_from,
#                              opt$K_to,
#                              opt$lmax,
#                              ds
#)
#print(calls)

calls <- matrix(nrow=1, ncol=13)
calls[1,1] = 'asd'
calls[1,2] = 13
print(calls)
calls

#install.packages("RJDBC",dep=TRUE)
library(RJDBC)
#download.file("http://zsibio.ii.pw.edu.pl:50007/repository/zsi-bio-raw/common/jdbc/postgresql-42.1.1.jar",destfile="postgresql-42.1.1.jar")
drv <- JDBC("org.postgresql.Driver", "./postgresql-42.1.1.jar",identifier.quote="`")
conn <- dbConnect(drv, "jdbc:postgresql://cdh00.ii.pw.edu.pl:15432/cnv-opt", "cnv-opt", "zsibio321")

for(i in 1:nrow(calls)) {
  call <- calls[i,]
  query <- paste("INSERT INTO TEST_CALLS (parameters_id, sample_name, chr, cnv, st_bp, ed_bp, length_kb, st_exon, ed_exon, raw_cov, norm_cov, copy_no, lratio, mBIC) VALUES ('", opt$id, "','", call[1], "','", call[2], "','", call[3], "','", call[4], "','", call[5], "','", call[6], "','", call[7], "','", call[8], "','", call[9], "','", call[10], "','", call[11], "','", call[12], "','", call[13], "');", sep="")
  print(query)
  dbSendUpdate(conn, query)
}
dbGetQuery(conn, "Select * from test_calls;")
dbDisconnect(conn)




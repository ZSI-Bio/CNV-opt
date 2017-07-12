#!/usr/bin/env Rscript
library(devtools)
#install('CODEXCOV')
library('CODEXCOV')
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

calls <- run_CODEXCOV(opt$mapp_thresh,
opt$cov_thresh_from,
opt$cov_thresh_to,
opt$length_thresh_from,
opt$length_thresh_to,
opt$gc_thresh_from,
opt$gc_thresh_to,
opt$K_from,
opt$K_to,
opt$lmax,
opt$cov_table
)

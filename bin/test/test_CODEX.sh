#!/bin/bash

bin/count_coverage.sh --coverage-function-file=R/count_coverage_for_single_sample_by_CODEX.R --tmp-dir=/tmp --bam-dir=$(Rscript R/get_toy_data.R dirPath) --bed-file=$(Rscript R/get_toy_data.R bedFile) --mapping-quality=20 --chromosome=22 --coverage-file=data/coverage.tsv

bin/run_caller.sh --caller=codex --conf-file=conf/caller.yaml --caller-path=R/CODEXCOV --coverage-file=data/coverage.tsv --sample-names-file=$(Rscript R/get_toy_data.R sampname) --bed-file=$(Rscript R/get_toy_data.R bedFile)


# Output for toy dataset from CODEX application:
# sample_name chr  cnv   st_bp      ed_bp      length_kb st_exon ed_exon raw_cov
# "NA18990"   "22" "dup" "22312814" "22326373" "13.56"   "60"    "72"    "1382" 
# norm_cov copy_no lratio  mBIC     pvalue 
# "997"    "3"     "61.83" "51.228" "1e-28"

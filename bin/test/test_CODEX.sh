#!/bin/bash

bin/count_coverage.sh --coverage-function-file= R/count_coverage_for_single_sample_by_CODEX.R --tmp-dir=/tmp --bam-dir=$(Rscript R/test/get_toy_data.R dirPath) --bed-file=$(Rscript R/test/get_toy_data.R bedFile) --mapping-quality=20 --chromosome=22 --coverage-file=data/EXAMPLE_BAMS/coverage.tsv

bin/run_caller.sh --caller=codex --conf-file=conf/caller.yaml --caller-path=R/run_CODEX.R --coverage-file=data/EXAMPLE_BAMS/coverage.tsv --sample-names=$(Rscript R/test/get_toy_data.R sampName) --bed-file=$(Rscript R/test/get_toy_data.R bedFile)

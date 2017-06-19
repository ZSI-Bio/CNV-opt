#!/bin/bash

bin/count_coverage.sh --coverage-function-file= R/count_coverage_for_single_sample_by_CODEX.R --tmp-dir=/tmp --bam-dir=/home/wiktor/CNV-opt/data/EXAMPLE_BAMS --bed-file=/home/wiktor/CNV-opt/data/EXAMPLE_BAMS/EXOME.bed --mapping-quality=20 --chromosome=22 --coverage-file=data/EXAMPLE_BAMS/coverage.tsv

bin/run_caller.sh --caller=codex --conf-file=conf/caller.yaml --caller-path=R/run_CODEX.R

#!/usr/bin/env Rscript
options(java.parameters = "-Xmx1512m")
library(devtools)
library('CNV.SIMULATOR')
library(optparse)
if (length(which(installed.packages()[,1] == "stringr")) == 0){install.packages("stringr",repos="https://cloud.r-project.org/")}
library(stringr)

option_list <- list(
  make_option("--input_cov_table", default="public.runner_calls",
              help="Calls table. [default %default]"),
  make_option("--input_bed", default="public.runner_calls",
              help="Calls table. [default %default]"),
  make_option("--input_males", default="public.runner_calls",
              help="Calls table. [default %default]"),
  make_option("--input_females", default="public.runner_calls",
              help="Calls table. [default %default]"),
  make_option("--output_cov_table", default="public.runner_calls",
              help="Calls table. [default %default]"),
  make_option("--output_generated_cnvs", default="public.runner_calls",
              help="Calls table. [default %default]"),
  make_option("--min_number_of_cnvs_per_sample", default="public.runner_calls",
              help="Calls table. [default %default]"),
  make_option("--min_number_of_regions", default="public.runner_calls",
              help="Calls table. [default %default]"),
  make_option("--max_number_of_regions", default="public.runner_calls",
              help="Calls table. [default %default]"),
  make_option("--simulation_mode", default="1",
              help="Calls table. [default %default]")
)
opt <- parse_args(OptionParser(option_list=option_list))

simulate_cnvs <- function(parameters, cov_table){
  simulated_cnvs <- run_CNV.SIMULATOR(input_cov_table,
                                      input_bed,
                                      input_males,
                                      input_females,
                                      output_cov_table,
                                      output_generated_cnvs,
                                      min_number_of_cnvs_per_sample,
                                      min_number_of_regions,
                                      max_number_of_regions,
                                      simulation_mode
  )
  simulated_cnvs
}

simulated_cnvs <- simulate_cnvs(opt$input_cov_table, 
                                opt$input_bed, 
                                opt$input_males, 
                                opt$input_females, 
                                opt$output_cov_table, 
                                opt$output_generated_cnvs, 
                                opt$min_number_of_cnvs_per_sample, 
                                opt$min_number_of_regions, 
                                opt$max_number_of_regions, 
                                opt$simulation_mode
)
print(simulated_cnvs)



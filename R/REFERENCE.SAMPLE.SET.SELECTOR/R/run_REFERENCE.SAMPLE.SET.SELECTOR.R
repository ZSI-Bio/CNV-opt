run_REFERENCE.SAMPLE.SET.SELECTOR <- function(select_method,
                                              num_refs,
                                              input_cov_table,
                                              output_reference_file){

  cov_table <- read.csv(input_cov_table)
  sampname <- unique(cov_table[,"sample_name"])
  targets <- cov_table[,c("target_id", "chr", "pos_min", "pos_max")]
  targets <- targets[!duplicated(targets[,"target_id"]),]
  targets <- targets[with(targets, order(target_id)), ]
  target_length <- targets[,"pos_max"] - targets[,"pos_min"]
  Y <- coverageObj1(cov_table, sampname, targets)$Y
  reference_samples <- list()

  for(i in 1:length(sampname)) {
    investigated_sample <- as.character(sampname[i])
    if(select_method == "canoes") {
      reference_samples_for_investigated_sample <- canoes_method(investigated_sample, Y, num_refs)$reference_samples
      reference_samples[[i]] <- c(investigated_sample, reference_samples_for_investigated_sample)
    } else if(select_method == "codex") {
      #reference_samples_for_investigated_sample <- codex_method(investigated_sample, Y, num_refs)$reference_samples
      #reference_samples[[i]] <- c(investigated_sample, reference_samples_for_investigated_sample)
    } else if(select_method == "exomedepth") {
      reference_samples_for_investigated_sample <- exomedepth_method(investigated_sample, Y, num_refs, target_length)$reference_samples
      reference_samples[[i]] <- c(investigated_sample, reference_samples_for_investigated_sample)
    } else if(select_method == "clamms") {
      #reference_samples_for_investigated_sample <- clamms_method(investigated_sample, Y, num_refs)$reference_samples
      #reference_samples[[i]] <- c(investigated_sample, reference_samples_for_investigated_sample)
    }
  }
  resultant_string <- ''
  for(i in 1:length(reference_samples)) {
    resultant_string <- paste(resultant_string, paste(reference_samples[[i]], collapse=","), '\n', sep="")
  }
  write(resultant_string, output_reference_file)
}

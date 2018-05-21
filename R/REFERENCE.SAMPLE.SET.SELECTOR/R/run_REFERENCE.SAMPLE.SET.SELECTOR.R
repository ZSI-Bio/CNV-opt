run_REFERENCE.SAMPLE.SET.SELECTOR <- function(select_method,
                                              num_refs,
                                              cov_thresh,
                                              input_cov_table,
                                              input_bed,
                                              output_reference_file){

  Y <- data.matrix(read.csv(input_cov_table))
  sampname <- colnames(Y)
  targets <- read.delim(input_bed)
  target_length <- targets[,"st_bp"] - targets[,"ed_bp"]
  reference_samples <- list()
  if() {
    kmeans_clusters <- kmeans_select_groups(Y, num_refs)
  }

  for(i in 1:length(sampname)) {
    investigated_sample <- as.character(sampname[i])
    print(paste("Processing ", investigated_sample, " sample ...", sep=""))
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
    } else if(select_method == "random") {
      reference_samples_for_investigated_sample <- random_method(investigated_sample, Y, num_refs)$reference_samples
      reference_samples[[i]] <- c(investigated_sample, reference_samples_for_investigated_sample)
    } else if(select_method == "canoes_cov_thresh") {
      reference_samples_for_investigated_sample <- canoes_cov_thresh_method(investigated_sample, Y, cov_thresh)$reference_samples
      reference_samples[[i]] <- c(investigated_sample, reference_samples_for_investigated_sample)
    } else if(select_method == "kmeans") {
      reference_samples_for_investigated_sample <- kmeans_method(investigated_sample, Y, kmeans_clusters)$reference_samples
      reference_samples[[i]] <- c(investigated_sample, reference_samples_for_investigated_sample)
    }
  }
  resultant_string <- ''
  for(i in 1:length(reference_samples)) {
    resultant_string <- paste(resultant_string, paste(reference_samples[[i]], collapse=","), '\n', sep="")
  }
  write(resultant_string, output_reference_file)
}

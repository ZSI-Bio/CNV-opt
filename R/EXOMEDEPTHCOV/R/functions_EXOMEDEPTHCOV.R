library(ExomeDepth)

coverageObj1 <- function(cov_table, sampname, targets_for_chr){
  Y <- matrix(data=as.integer(0), nrow = nrow(targets_for_chr), ncol = 0)
  for(sample in sampname) {
    cov_targets_for_sample <- cov_table[cov_table[,"sample_name"] == sample,]
    cov_targets_for_sample <- cov_targets_for_sample[with(cov_targets_for_sample, order(target_id)), ]
    Y <- cbind(Y, cov_targets_for_sample[,"read_count"])
  }
  colnames(Y) <- sampname
  rownames(Y) <- targets_for_chr[,"target_id"]
  return(list(Y=Y))
}



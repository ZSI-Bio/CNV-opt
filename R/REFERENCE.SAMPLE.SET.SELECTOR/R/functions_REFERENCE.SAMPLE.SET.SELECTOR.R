library(ExomeDepth)

coverageObj1 <- function(cov_table, sampname, targets){
  Y <- matrix(data=as.integer(0), nrow = nrow(targets), ncol = 0)
  for(sample in sampname) {
    cov_targets_for_sample <- cov_table[cov_table[,"sample_name"] == sample,]
    cov_targets_for_sample <- cov_targets_for_sample[with(cov_targets_for_sample, order(target_id)), ]
    Y <- cbind(Y, cov_targets_for_sample[,"read_count"])
  }
  colnames(Y) <- sampname
  rownames(Y) <- targets[,"target_id"]
  return(list(Y=Y))
}

canoes_method <- function(investigated_sample, Y, num_refs){
  samples <- colnames(Y)
  cov <- cor(Y[, samples], Y[, samples])
  reference_samples <- setdiff(samples, investigated_sample)
  covariances <- cov[investigated_sample, reference_samples]
  reference_samples <- names(sort(covariances, 
          decreasing=T)[1:min(num_refs, length(covariances))])
  return(list(reference_samples=reference_samples))
}

exomedepth_method <- function(investigated_sample, Y, num_refs, target_length){
  samples <- colnames(Y)
  reference_samples <- setdiff(samples, investigated_sample)
  reference_set <- select.reference.set(test.counts = Y[,investigated_sample],
                                        reference.counts = Y[,reference_samples],
                                        bin.length = target_length,
                                        n.bins.reduced = 10000)
  #reference_samples <- reference_set$reference.choice
  reference <- reference_set$summary.stats[1:num_refs,'ref.samples']
  reference_samples <- c()
  for (s in reference)
    reference_samples <- c(reference_samples, c(s)) 
  return(list(reference_samples=reference_samples))
}


canoes_method <- function(investigated_sample, Y, num_refs){
  if (num_refs == 0) {
    num_refs <- 30  # in CANOES application num_refs is default set to 30
  }
  samples <- colnames(Y)
  cov <- cor(Y[, samples], Y[, samples])
  reference_samples <- setdiff(samples, investigated_sample)
  covariances <- cov[investigated_sample, reference_samples]
  reference_samples <- names(sort(covariances, 
          decreasing=T)[1:min(num_refs, length(covariances))])
  return(list(reference_samples=reference_samples))
}

canoes_cov_thresh_method <- function(investigated_sample, Y, cov_thresh){
  samples <- colnames(Y)
  cov <- cor(Y[, samples], Y[, samples])
  reference_samples <- setdiff(samples, investigated_sample)
  covariances <- cov[investigated_sample, reference_samples]
  num_refs <- sum(covariances > cov_thresh)
  reference_samples <- names(sort(covariances, 
          decreasing=T)[1:num_refs])
  return(list(reference_samples=reference_samples))
}

exomedepth_method <- function(investigated_sample, Y, num_refs, target_length){
  library(ExomeDepth)
  samples <- colnames(Y)
  reference_samples <- setdiff(samples, investigated_sample)
  reference_set <- select.reference.set(test.counts = Y[,investigated_sample],
                                        reference.counts = Y[,reference_samples],
                                        bin.length = target_length,
                                        n.bins.reduced = 10000)
  if (num_refs == 0) {
    reference_samples <- reference_set$reference.choice
  } else {
    reference <- reference_set$summary.stats[1:num_refs,'ref.samples']
    reference_samples <- c()
    for (s in reference)
      reference_samples <- c(reference_samples, c(s))
  } 
  return(list(reference_samples=reference_samples))
}

random_method <- function(investigated_sample, Y, num_refs){
  samples <- colnames(Y)
  reference_samples <- setdiff(samples, investigated_sample)
  reference_samples <- reference_samples[sample(1:length(reference_samples), num_refs, replace=F)]
  return(list(reference_samples=reference_samples))
}

kmeans_select_groups <- function(Y, number_of_clusters){
  samples <- colnames(Y)
  cov <- cor(Y[, samples], Y[, samples])
  d <- cov
  for(i in 1:nrow(d)) {
    d[i,] <- cov[samples[i], samples]
  }
  d <- 1-d
  c <- c()
  for(i in 1:ncol(d)-1) {
    c <- c(c, d[(i+1):nrow(d),i])
  }
  d <- dist(d)
  for(i in 1:length(d)) {
    d[i] <- c[i]
  }
  km1 <- kmeans(d, number_of_clusters, nstart=100)
  return(list(clusters=km1))
}

kmeans_method <- function(investigated_sample, Y, kmeans_clusters){
  samples <- colnames(Y)
  cluster_id <- kmeans_clusters$cluster[investigated_sample]
  reference_samples <- c()
  list_index <- 1
  for(i in kmeans_clusters$cluster) {
    if(i == cluster_id) {
      reference_samples <- c(reference_samples, samples[list_index])
    }
    list_index <- list_index + 1
  }
  reference_samples <- setdiff(reference_samples, investigated_sample)
  return(list(reference_samples=reference_samples))
}

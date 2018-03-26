
coverageObj1 <- function(cov_table, sampname, targets_for_chr, chr){
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


# from CODEX package
getgc <- function(chr, ref) {
  library(GenomeInfoDb)
  library(BSgenome.Hsapiens.UCSC.hg19)
  if (chr == "X" | chr == "x" | chr == "chrX" | chr == "chrx") {
    chrtemp <- 23
  } else if (chr == "Y" | chr == "y" | chr == "chrY" | chr == "chry") {
    chrtemp <- 24
  } else {
    chrtemp <- as.numeric(mapSeqlevels(as.character(chr), "NCBI")[1])
  }
  if (length(chrtemp) == 0) 
    message("Chromosome cannot be found in NCBI Homo sapiens database!")
  chrm <- unmasked(Hsapiens[[chrtemp]])
  seqs <- Views(chrm, ref)
  af <- alphabetFrequency(seqs, baseOnly = TRUE, as.prob = TRUE)
  gc <- round((af[, "G"] + af[, "C"]) * 100,2)
  gc
}

# CallCNVs
#     Calls CNVs in sample of interest
# Arguments:
#   sample.name:
#     sample to call CNVs in (should correspond to a column in counts)
#   counts: 
#     count matrix, first five columns should be 
#       target: consecutive numbers for targets (integer)
#       chromosome: chromosome number (integer-valued) 
#         (support for sex chromosomes to come)
#       start: start position of probe (integer)
#       end: end position of probe (integer)
#       gc: gc content (real between 0 and 1)
#       subsequent columns should include counts for each probe for samples
#   p:
#     average rate of occurrence of CNVs (real) default is 1e-08
#   D:
#     expected distance between targets in a CNV (integer) default is 70,000
#   Tnum:
#     expected number of targets in a CNV (integer) default is 6
#   num_of_samples_in_reference_set
#     maximum number of reference samples to use (integer) default is 30
#     the weighted variance calculations will take a long time if too 
#     many reference samples are used
# Returns: 
#   data frame with the following columns:
#      SAMPLE: name of sample
#      CNV: DEL of DUP
#      INTERVAL: CNV coordinates in the form chr:start-stop
#      KB: length of CNV in kilobases
#      CHR: chromosome
#      MID_BP: middle base pair of CNV
#      TARGETS: target numbers of CNV in the form start..stop
#      NUM_TARG: how many targets are in the CNV
#      Q_SOME: a Phred-scaled quality score for the CNV
CallCNVs <- function(sample.name, reference.samples, counts, p=1e-08, Tnum=6, D=70000, get.dfs=F, homdel.mean=0.2){
  library(IRanges)
  library(BSgenome.Hsapiens.UCSC.hg19)
  library(Biostrings)
  library(Rsamtools)
  library(GenomeInfoDb)
  library(S4Vectors)
  if (!sample.name %in% names(counts)){stop("No column for sample ", sample.name, " in counts matrix")}
  if (length(setdiff(names(counts)[1:5], c("target", "chromosome", "start", "end", "gc"))) > 0){
    stop("First five columns of counts matrix must be target, chromosome, start, end, gc")
  }
  if (length(setdiff(unique(counts$chromosome), seq(1:22))) > 0) {
    # remove sex chromosomes
    cat("Trying to remove sex chromosomes and 'chr' prefixes\n")
    counts <- subset(counts, !chromosome %in% c("chrX", "chrY", "X", "Y"))
    if (sum(grepl("chr", counts$chromosome))==length(counts$chromosome)){
      counts$chromosome <- gsub("chr", "", counts$chromosome)
    }
    counts$chromosome <- as.numeric(counts$chromosome)
    if (length(setdiff(unique(counts$chromosome), seq(1:22))) > 0) 
      stop("chromosome must take value in range 1-22 (support for sex chromosomes to come)")
  }
  library(plyr)
  counts <- arrange(counts, chromosome, start)
  if (p <= 0){
    stop("parameter p must be positive")
  }
  if (Tnum <= 0){
    stop("parameter Tnum must be positive")
  }
  if (D <= 0){
    stop("parameter D must be positive")
  }
  #if (numrefs <= 0){
  #  stop("parameter numrefs must be positive")
  #}
  sample.names <- colnames(counts)[-seq(1,5)]
  # find mean coverage of probes
  mean.counts <- mean(apply(counts[, sample.names], 2, mean))
  # normalize counts; round so we can use negative binomial
  counts[, sample.names] <- apply(counts[, sample.names], 2, 
        function(x, mean.counts) 
                 round(x * mean.counts / mean(x)), mean.counts)
  # calculate covariance of read count across samples
  #cov <- cor(counts[, sample.names], counts[, sample.names])
  #reference.samples <- setdiff(sample.names, sample.name)
  #covariances <- cov[sample.name, reference.samples]
  #reference.samples <- names(sort(covariances, 
  #        decreasing=T)[1:min(numrefs, length(covariances))])
  Y <- data.matrix(counts[,6:ncol(counts)])
  #library('REFERENCE.SAMPLE.SET.SELECTOR')
  #reference.samples <- run_REFERENCE.SAMPLE.SET.SELECTOR(sample.name,
  #                                                       Y,
  #                                                       reference_set_select_method,
  #                                                       num_of_samples_in_reference_set,
  #                                                       target_length)
  sample.mean.counts <- mean(counts[, sample.name])
  sample.sumcounts <- apply(counts[, reference.samples], 2, sum)
  # normalize reference samples to sample of interest
  counts[, reference.samples] <- apply(counts[, reference.samples], 2, 
        function(x, sample.mean.counts) 
                round(x * sample.mean.counts / 
                mean(x)), sample.mean.counts)  
  # select reference samples and weightings using non-negative least squares
  b <- counts[, sample.name]
  A <- as.matrix(counts[, reference.samples])
  library(nnls)
  all <- nnls(A, b)$x
  est <- matrix(0, nrow=50, ncol=length(reference.samples))
  set.seed(1)
  for (i in 1:50){
    d <- sample(nrow(A), min(500, nrow(A)))
    est[i, ] <- nnls(A[d, ], b[d])$x
  }
  weights <- colMeans(est)
  sample.weights <- weights / sum(weights)
  library(Hmisc)
  # calculate weighted mean of read count
  # this is used to calculate emission probabilities
  counts$mean <- apply(counts[, reference.samples], 
                       1, wtd.mean, sample.weights)
  targets <- counts$target
  # exclude probes with all zero counts
  nonzero.rows <- counts$mean > 0
  nonzero.rows.df <- data.frame(target=counts$target, 
                                nonzero.rows=nonzero.rows)

  counts <- counts[nonzero.rows, ]
  # get the distances between consecutive probes
  distances <- GetDistances(counts)
  # estimate the read count variance at each probe
  var.estimate <- EstimateVariance(counts, reference.samples, 
                                               sample.weights)
  emission.probs <- EmissionProbs(counts[, sample.name], 
                        counts$mean, var.estimate$var.estimate, 
                        counts[, "target"])
  if (get.dfs){
    return(list(emission.probs=emission.probs, distances=distances))
  }
  # call CNVs with the Viterbi algorithm
  viterbi.state <- Viterbi(emission.probs, distances, p, Tnum, D)  
  # format the CNVs
  cnvs <- PrintCNVs(sample.name, viterbi.state, 
                         counts)
  # if there aren't too many CNVs, calculate the Q_SOME
  if (nrow(cnvs) > 0 & nrow(cnvs) <= 50){
    #qualities <- GenotypeCNVs(cnvs, sample.name, counts, p, Tnum, D, numrefs=30, 
    #                      emission.probs=emission.probs, 
    #                      distances=distances)
    #for (i in 1:nrow(cnvs)){
    #  cnvs$Q_SOME[i] <- ifelse(cnvs$CNV[i]=="DEL", qualities[i, "SQDel"], 
    #                           qualities[i, "SQDup"])
    #}
  }
  data <- as.data.frame(cbind(counts$target, counts$mean, var.estimate$var.estimate, counts[, sample.name]))
  names(data) <- c("target", "countsmean", "varestimate", "sample")
  if (nrow(cnvs) > 0){
    cnvs <- CalcCopyNumber(data, cnvs, homdel.mean)
  }
  return(cnvs)
}

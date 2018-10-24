library(ExomeDepth)
library(methods)

run_EXOMEDEPTHCOV <- function(input_cov_table,
                              input_bed,
                              reference_sample_set_file,
                              output_calls_file){

  con <- file(reference_sample_set_file, open='r')
  reference_sample_set <- readLines(con)
  Y <- read.csv(input_cov_table)
  sampname <- colnames(Y)
  targets <- read.delim(input_bed)
  rownames(Y) <- 1:nrow(Y)
  rownames(targets) <- 1:nrow(targets)
  calls <- data.frame(matrix(nrow=0, ncol=13))

  for (i in 1:length(reference_sample_set)) {
    if (reference_sample_set[[i]] == '') {
      next()
    }
    samples <- unlist(strsplit(reference_sample_set[[i]], ','))
    actual_sample <- samples[1]
    reference_samples <- samples[-1]

    ## ----construct.ref-------------------------------------------------------
    my.matrix <- as.matrix(Y[,reference_samples])
    my.reference.selected <- apply(X = my.matrix, 
                                   MAR = 1, 
                                   FUN = sum)

    ## ----build.complete------------------------------------------------------
    all.exons <- new('ExomeDepth',
                     test = Y[,actual_sample],
                     reference = my.reference.selected,
                     formula = 'cbind(test, reference) ~ 1')

    ## ----call.CNVs-----------------------------------------------------------
    all.exons <- ExomeDepth::CallCNVs(x = all.exons, 
                                      transition.probability = 10^-4, 
                                      chromosome = targets[,"chr"], 
                                      start = targets[,"st_bp"], 
                                      end = targets[,"ed_bp"], 
                                      name = rep('name', nrow(Y)))
    print(all.exons@CNV.calls)
    if (nrow(all.exons@CNV.calls) > 0) {
      actual_sample_column <- data.frame(matrix(rep(actual_sample, nrow(all.exons@CNV.calls)), nrow=nrow(all.exons@CNV.calls))) 
      callsIt <- cbind(actual_sample_column, all.exons@CNV.calls)
      colnames(callsIt) <- c(c, colnames(all.exons@CNV.calls))
      if (nrow(calls)==0){calls <- data.frame(matrix(nrow=0, ncol=ncol(callsIt)))} 
      calls <- rbind(calls, callsIt)
    }
  }
  # unify names of output columns
  # deletion -> del
  # duplication -> dup
  # generate copy_no
  if (nrow(calls) != 0) {
    calls[calls == 'deletion'] <- 'del'
    calls[calls == 'duplication'] <- 'dup'
    calls[,1] <- as.character(calls[,1])
    colnames(calls)[1] <- 'sample_name'
  }
  colnames(calls)[colnames(calls) == 'sample_name'] <- 'sample_name'
  colnames(calls)[colnames(calls) == 'start.p'] <- 'st_exon'
  colnames(calls)[colnames(calls) == 'end.p'] <- 'ed_exon'
  colnames(calls)[colnames(calls) == 'type'] <- 'cnv'
  calls <- calls[,-which(names(calls) %in% c('nexons', 'id'))]
  colnames(calls)[colnames(calls) == 'start'] <- 'st_bp'
  colnames(calls)[colnames(calls) == 'end'] <- 'ed_bp'
  colnames(calls)[colnames(calls) == 'chromosome'] <- 'chr'
  colnames(calls)[colnames(calls) == 'BF'] <- 'exomedepth_BF'
  colnames(calls)[colnames(calls) == 'reads.expected'] <- 'norm_cov'
  colnames(calls)[colnames(calls) == 'reads.observed'] <- 'raw_cov'
  colnames(calls)[colnames(calls) == 'reads.ratio'] <- 'copy_no'
  calls[colnames(calls) == 'copy_no'] <- round(calls[colnames(calls) == 'raw_cov'] / (calls[colnames(calls) == 'norm_cov'] / 2))
  write.csv(calls, output_calls_file, row.names=F)
}

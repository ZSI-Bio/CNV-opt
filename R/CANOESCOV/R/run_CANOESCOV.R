library(methods)

run_CANOESCOV <- function(reference_set_select_method,
                          num_of_samples_in_reference_set,
                          cov_table){

  sampname <- unique(cov_table[,"sample_name"])
  targets <- cov_table[,c("target_id", "chr", "pos_min", "pos_max")]
  targets <- targets[!duplicated(targets[,"target_id"]),]
  targets <- targets[with(targets, order(target_id)), ]
  
  calls <- data.frame(matrix(nrow=0, ncol=13))
  chrs <- c(1:22, "X", "Y", paste0("chr",c(1:22, "X", "Y")))
  library(IRanges)
  for(chr in chrs) {
    targets_for_chr <- targets[targets[,"chr"] == chr,]
    ref <- IRanges(start = targets_for_chr[,"pos_min"], end = targets_for_chr[,"pos_max"])
    if (length(ref) == 0) {    # 0 elements for specified chromosome in bed
      next()
    }
    Y <- coverageObj1(cov_table, sampname, targets_for_chr, chr)$Y

    for (actual_sample_id in 1:length(sampname)) {
      actual_sample <- sampname[actual_sample_id]
      ## ----reference.selection-------------------------------------------------
      target_length <- c()
      for (i in 1:nrow(Y)) {
        target_length <- c(target_length, width(ref[i]))
      }
      reference_samples <- run_REFERENCE.SAMPLE.SET.SELECTOR(actual_sample,
                                                             Y,
                                                             reference_set_select_method,
                                                             num_of_samples_in_reference_set,
                                                             target_length)

      ## ----construct.ref-------------------------------------------------------
      my.matrix <- as.matrix(Y[,reference_samples])
      my.reference.selected <- apply(X = my.matrix, 
                                     MAR = 1, 
                                     FUN = sum)

      ## ----build.complete------------------------------------------------------
      all.exons <- new('ExomeDepth',
                       test = Y[,actual_sample_id],
                       reference = my.reference.selected,
                       formula = 'cbind(test, reference) ~ 1')

      ## ----call.CNVs-----------------------------------------------------------
      all.exons <- CallCNVs(x = all.exons, 
                            transition.probability = 10^-4, 
                            chromosome = rep(chr, nrow(Y)), 
                            start = start(ref), 
                            end = end(ref), 
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
  calls






















  # read in the data
  gc <- read.table("gc.txt")$V2
  canoes.reads <- read.table("canoes.reads.txt")
  # rename the columns of canoes.reads
  sample.names <- paste("S", seq(1:26), sep="")
  names(canoes.reads) <- c("chromosome", "start", "end", sample.names)
  # create a vector of consecutive target ids
  target <- seq(1, nrow(canoes.reads))
  # combine the data into one data frame
  canoes.reads <- cbind(target, gc, canoes.reads)
  # call CNVs in each sample
  # create a vector to hold the results for each sample
  xcnv.list <- vector('list', length(sample.names))
  for (i in 1:length(sample.names)){
    xcnv.list[[i]] <- CallCNVs(sample.names[i], canoes.reads) 
  }
  # combine the results into one data frame
  xcnvs <- do.call('rbind', xcnv.list)
  # inspect the first two CNV calls
  print(xcnvs)
}

library(ExomeDepth)
library(methods)
library(CODEX)

run_EXOMEDEPTHCOV <- function(mapp_thresh,
                           cov_thresh_from,
                           cov_thresh_to,
                           length_thresh_from,
                           length_thresh_to,
                           gc_thresh_from,
                           gc_thresh_to,
                           K_from,
                           K_to,
                           lmax,
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

    gc <- getgc(chr, ref)
    mapp <- getmapp(chr, ref)
    qcObj <- qc(Y, sampname, chr, ref, mapp, gc, cov_thresh = c(20, 4000), 
                length_thresh = c(20, 2000), mapp_thresh = 0.9, gc_thresh = c(20, 80))
    Y_qc <- qcObj$Y_qc; sampname_qc <- qcObj$sampname_qc; gc_qc <- qcObj$gc_qc
    mapp_qc <- qcObj$mapp_qc; ref_qc <- qcObj$ref_qc; qcmat <- qcObj$qcmat

    for (actual_sample_id in 1:length(sampname_qc)) {
      actual_sample <- sampname_qc[actual_sample_id]
      ## ----reference.selection-------------------------------------------------
      target_length <- c()
      for (i in 1:nrow(Y_qc)) {
        target_length <- c(target_length, width(ref_qc[i]))
      }
      reference_set <- select.reference.set (test.counts = Y_qc[,actual_sample_id],
                                             reference.counts = Y_qc[,-actual_sample_id],
                                             bin.length = target_length,
                                             n.bins.reduced = 10000)

      ## ----construct.ref-------------------------------------------------------
      my.matrix <- as.matrix(Y_qc[,reference_set$reference.choice])
      my.reference.selected <- apply(X = my.matrix, 
                                     MAR = 1, 
                                     FUN = sum)

      ## ----build.complete------------------------------------------------------
      all.exons <- new('ExomeDepth',
                       test = Y_qc[,actual_sample_id],
                       reference = my.reference.selected,
                       formula = 'cbind(test, reference) ~ 1')

      ## ----call.CNVs-----------------------------------------------------------
      all.exons <- CallCNVs(x = all.exons, 
                            transition.probability = 10^-4, 
                            chromosome = rep(chr, nrow(Y_qc)), 
                            start = start(ref_qc), 
                            end = end(ref_qc), 
                            name = rep('name', nrow(Y_qc)))
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
  calls[calls == 'deletion'] <- 'del'
  calls[calls == 'duplication'] <- 'dup'
  calls[,1] <- as.character(calls[,1])
  colnames(calls)[1] <- 'sample_name'
  calls
}

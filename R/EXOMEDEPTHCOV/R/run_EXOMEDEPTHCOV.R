library(ExomeDepth)
library(methods)
library(CODEX)

run_EXOMEDEPTH <- function(mapp_thresh,
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
  
  finalcall <- matrix(nrow=0, ncol=13)
  chrs <- c(1:22, "X", "Y", paste0("chr",c(1:22, "X", "Y")))
  
  for(chr in chrs) {
    targets_for_chr <- targets[targets[,"chr"] == chr,]
    ref <- IRanges(start = targets_for_chr[,"pos_min"], end = targets_for_chr[,"pos_max"])
    if (length(ref) == 0) {    # 0 elements for specified chromosome in bed
      next()
    }
    ###################################################
    ### code chunk number 4: coverageObj1
    ###################################################
    Y <- coverageObj1(cov_table, sampname, targets_for_chr, chr)$Y

    args = commandArgs(trailingOnly=TRUE)
    sample_id <- strtoi(args[2])
    actual_sample <- sampname[sample_id,1]

    ###################################################
    ### code chunk number 5: gcmapp1
    ###################################################
    gc <- getgc(chr, ref)
    mapp <- getmapp(chr, ref)
  
    ###################################################
    ### code chunk number 6: qcObj1
    ###################################################
    qcObj <- qc(Y, sampname, chr, ref, mapp, gc, cov_thresh = c(20, 4000), 
                length_thresh = c(20, 2000), mapp_thresh = 0.9, gc_thresh = c(20, 80))
    Y_qc <- qcObj$Y_qc; sampname_qc <- qcObj$sampname_qc; gc_qc <- qcObj$gc_qc
    mapp_qc <- qcObj$mapp_qc; ref_qc <- qcObj$ref_qc; qcmat <- qcObj$qcmat

    ## ----reference.selection-------------------------------------------------
    target_length <- c()
    for (i in 1:nrow(Y_qc)) {
      target_length <- c(target_length, width(ref_qc[i]))
    }
    print(target_length)
    reference_set <- select.reference.set (test.counts = Y_qc[,sample_id],
                                           reference.counts = Y_qc[,-sample_id],
                                           bin.length = target_length,
                                           n.bins.reduced = 10000)

    ## ----construct.ref-------------------------------------------------------
    my.matrix <- as.matrix(Y_qc[,reference_set$reference.choice])
    my.reference.selected <- apply(X = my.matrix, 
                                   MAR = 1, 
                                   FUN = sum)

    ## ----build.complete------------------------------------------------------
    all.exons <- new('ExomeDepth',
                     test = Y_qc[,sample_id],
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
    calls <- cbind(rep(actual_sample, nrow(all.exons@CNV.calls)), all.exons@CNV.calls)
    colnames(calls) <- c('sample_name', colnames(all.exons@CNV.calls))
    write.csv(calls, file=paste('calls_', chr, '_', actual_sample, '.csv', sep=""))
    print(calls)
    calls

  }
  finalcall
}

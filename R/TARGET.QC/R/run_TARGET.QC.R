run_TARGET.QC <- function(mapp_thresh,
                          cov_thresh_from,
                          cov_thresh_to,
                          length_thresh_from,
                          length_thresh_to,
                          gc_thresh_from,
                          gc_thresh_to,
                          input_cov_table,
                          output_cov_table){
  #mapp_thresh <- 0.9
  #cov_thresh_from <- 20
  #cov_thresh_to <- 4000
  #length_thresh_from <- 20
  #length_thresh_to <- 2000
  #gc_thresh_from <- 20
  #gc_thresh_to <- 80
  #lmax <- 200
  cov_table <- read.csv(input_cov_table)
  sampname <- unique(cov_table[,"sample_name"])
  targets <- cov_table[,c("target_id", "chr", "pos_min", "pos_max")]
  targets <- targets[!duplicated(targets[,"target_id"]),]
  targets <- targets[with(targets, order(target_id)), ]
  cov_table_qc <- matrix(nrow=0, ncol=6)
  colnames(cov_table_qc) <- colnames(cov_table)

  chrs <- c(1:22, "X", "Y", paste0("chr",c(1:22, "X", "Y")))
  for(chr in chrs) {
    targets_for_chr <- targets[targets[,"chr"] == chr,]
    ref <- IRanges(start = targets_for_chr[,"pos_min"], end = targets_for_chr[,"pos_max"])
    if (length(ref) == 0) {    # 0 elements for specified chromosome in bed
      next()
    }
    Y <- coverageObj1(cov_table, sampname, targets_for_chr, chr)$Y
    gcmapp1_result <- gcmapp1(chr, ref)
    gc <- gcmapp1_result$gc
    mapp <- gcmapp1_result$mapp

    qcObj1_result <- qcObj1(Y, sampname, chr, ref, mapp, gc, cov_thresh = c(cov_thresh_from, cov_thresh_to), 
                        length_thresh = c(length_thresh_from, length_thresh_to), mapp_thresh, 
                        gc_thresh = c(gc_thresh_from, gc_thresh_to))
    Y_qc <- qcObj1_result$Y_qc
    sampname_qc <- qcObj1_result$sampname_qc
    ref_qc <- qcObj1_result$ref_qc
    colnames(Y_qc) <- sampname_qc
    for(sample in colnames(Y_qc)) {
      new_cov_table_qc_rows <- cbind(sample, rownames(Y_qc), chr, start(ref_qc), end(ref_qc), Y_qc[,sample])
      cov_table_qc <- rbind(cov_table_qc, new_cov_table_qc_rows)
    }
  }
  cov_table_qc <- as.data.frame(cov_table_qc)
  cov_table_qc[,"pos_min"] <- strtoi(cov_table_qc[,"pos_min"])
  cov_table_qc[,"pos_max"] <- strtoi(cov_table_qc[,"pos_max"])
  cov_table_qc[,"target_id"] <- strtoi(cov_table_qc[,"target_id"])
  cov_table_qc[,"read_count"] <- strtoi(cov_table_qc[,"read_count"])
  write.csv(cov_table_qc, output_cov_table, row.names=F, quote=F)
}

#  sample_name target_id chr  pos_min  pos_max read_count
#1     NA19012    193524   Y 25426932 25427053          0
#2     NA19012    193525   Y 25431556 25431676          0
#3     NA19012    193526   Y 25535089 25535239          0
#4     NA19012    193527   Y 25537286 25537526          0
#5     NA19012    193528   Y 25538793 25538913          0

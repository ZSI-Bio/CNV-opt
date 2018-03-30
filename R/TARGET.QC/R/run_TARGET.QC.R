run_TARGET.QC <- function(mapp_thresh,
                          cov_thresh_from,
                          cov_thresh_to,
                          length_thresh_from,
                          length_thresh_to,
                          gc_thresh_from,
                          gc_thresh_to,
                          input_cov_table,
                          output_cov_table,
                          input_bed,
                          output_bed){
  #mapp_thresh <- 0.9
  #cov_thresh_from <- 20
  #cov_thresh_to <- 4000
  #length_thresh_from <- 20
  #length_thresh_to <- 2000
  #gc_thresh_from <- 20
  #gc_thresh_to <- 80
  Y <- read.csv(input_cov_table)
  sampname <- colnames(Y)
  targets <- read.delim(input_bed)
  ref <- IRanges(start = targets[,"st_bp"], end = targets[,"ed_bp"])
  gcmapp1_result <- gcmapp1(targets[1,"chr"], ref)
  gc <- gcmapp1_result$gc
  mapp <- gcmapp1_result$mapp
  qcObj1_result <- qcObj1(Y, sampname, targets[1,"chr"], ref, mapp, gc, cov_thresh = c(cov_thresh_from, cov_thresh_to), 
                          length_thresh = c(length_thresh_from, length_thresh_to), mapp_thresh, 
                          gc_thresh = c(gc_thresh_from, gc_thresh_to))
  Y_qc <- qcObj1_result$Y_qc
  sampname_qc <- qcObj1_result$sampname_qc
  ref_qc <- qcObj1_result$ref_qc
  colnames(Y_qc) <- sampname_qc
  write.csv(Y_qc, output_cov_table, row.names=F, quote=F)
  write.csv(ref[rownames(ref_qc),], output_bed, row.names=F, quote=F)
}


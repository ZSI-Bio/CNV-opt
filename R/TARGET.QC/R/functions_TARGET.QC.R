library(CODEX)

coverageObj1 <- function(cov_table, sampname, targets_for_chr, chr){
  Y <- matrix(data=as.integer(0), nrow = nrow(targets_for_chr), ncol = length(sampname))
  colnames(Y) <- sampname
  rownames(Y) <- targets_for_chr[,"target_id"]
  cov_targets_for_chr <- cov_table[cov_table[,"chr"] == chr,]
  for(i in 1:nrow(cov_targets_for_chr)) {
    cov_row <- cov_targets_for_chr[i,]
    Y[toString(cov_row[,"target_id"]),toString(cov_row[,"sample_name"])] = as.integer(cov_row[,"read_count"])
  }
  return(list(Y=Y))
}

gcmapp1 <- function(chr, ref){
  gc <- getgc(chr, ref)
  mapp <- getmapp(chr, ref)
  return(list(gc=gc, mapp=mapp))
}

qcObj1 <- function(Y, sampname, chr, ref, mapp, gc, cov_thresh, length_thresh, mapp_thresh, gc_thresh){
  qcObj1_result <- qc(Y, sampname, chr, ref, mapp, gc, cov_thresh, length_thresh, mapp_thresh, gc_thresh)
  Y_qc <- qcObj1_result$Y_qc
  sampname_qc <- qcObj1_result$sampname_qc
  gc_qc <- qcObj1_result$gc_qc
  ref_qc <- qcObj1_result$ref_qc
  return(list(Y_qc=Y_qc, sampname_qc=sampname_qc, gc_qc=gc_qc, ref_qc=ref_qc))
}

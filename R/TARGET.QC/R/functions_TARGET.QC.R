library(CODEX)

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

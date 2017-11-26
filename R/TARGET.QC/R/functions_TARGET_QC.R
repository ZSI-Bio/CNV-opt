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

normObj1 <- function(Y_qc, gc_qc, K){
  normObj_result <- normalize(Y_qc, gc_qc, K)
  Yhat <- normObj_result$Yhat
  AIC <- normObj_result$AIC
  BIC <- normObj_result$BIC
  RSS <- normObj_result$RSS
  K <- normObj_result$K
  return(list(Yhat=Yhat, AIC=AIC, BIC=BIC, RSS=RSS, K=K))
}

normObj2 <- function(Y_qc, gc_qc, K, normal_index){
  normObj_result <- normalize2(Y_qc, gc_qc, K, normal_index)
  Yhat <- normObj_result$Yhat
  AIC <- normObj_result$AIC
  BIC <- normObj_result$BIC
  RSS <- normObj_result$RSS
  K <- normObj_result$K
  return(list(Yhat=Yhat, AIC=AIC, BIC=BIC, RSS=RSS, K=K))
}

segment1 <- function(Y_qc, Yhat, optK, K, sampname_qc,
                     ref_qc, chr, lmax, mode){
  finalcall <- segment(Y_qc, Yhat, optK, K, sampname_qc,
                         ref_qc, chr, lmax, mode)
  return(list(finalcall=finalcall))
}

unify_calls_format <- function(finalcall){
  colnames(finalcall)[colnames(finalcall) == 'lratio'] <- 'codex_lratio'
  colnames(finalcall)[colnames(finalcall) == 'mBIC'] <- 'codex_mBIC'
  return(list(finalcall=finalcall))
}

calc_func <- function(a, b){
  return (a + b)
}

library(CODEX)

coverageObj1 <- function(cov_file, sampname){
  # [TODO] dodac filtr wartosci (wierszy) dla odpowiedniego chromosomu, ale to chyba jest, ale trzeba przetestowac !!!
  Y <- scan(cov_file)
  Y <- matrix(Y, ncol = length(sampname), byrow = TRUE)
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

segment1 <- function(BIC, Y_qc, Yhat, K, sampname_qc,
                     ref_qc, chr, lmax, mode){
  optK = K[which.max(BIC)]
  finalcall <- matrix(nrow=0,ncol=14)
  finalcall <- segment(Y_qc, Yhat, optK, K, sampname_qc,
                         ref_qc, chr, lmax, mode)
  return(list(finalcall=finalcall))
}

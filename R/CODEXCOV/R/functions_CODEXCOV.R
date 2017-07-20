library(CODEX)

#' Function Dexcription
#'
#' Function description.
#' @param cov_file
#' @param sampname
#' @keywords 
#' @export
#' @examples
#' coverageObj1
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

#' Function Dexcription
#'
#' Function description.
#' @param chr
#' @param ref
#' @keywords 
#' @export
#' @examples
#' coverageObj1
gcmapp1 <- function(chr, ref){
  gc <- getgc(chr, ref)
  mapp <- getmapp(chr, ref)
  return(list(gc=gc, mapp=mapp))
}

#' Function Dexcription
#'
#' Function description.
#' @param Y
#' @param sampname
#' @param chr
#' @param ref
#' @param mapp
#' @param gc
#' @param cov_thresh
#' @param length_thresh
#' @param mapp_thresh
#' @param gc_thresh
#' @keywords 
#' @export
#' @examples
#' coverageObj1
qcObj1 <- function(Y, sampname, chr, ref, mapp, gc, cov_thresh, length_thresh, mapp_thresh, gc_thresh){
  qcObj1_result <- qc(Y, sampname, chr, ref, mapp, gc, cov_thresh, length_thresh, mapp_thresh, gc_thresh)
  Y_qc <- qcObj1_result$Y_qc
  sampname_qc <- qcObj1_result$sampname_qc
  gc_qc <- qcObj1_result$gc_qc
  ref_qc <- qcObj1_result$ref_qc
  return(list(Y_qc=Y_qc, sampname_qc=sampname_qc, gc_qc=gc_qc, ref_qc=ref_qc))
}

#' Function Dexcription
#'
#' Function description.
#' @param Y_qc
#' @param gc_qc
#' @param K
#' @keywords 
#' @export
#' @examples
#' coverageObj1
normObj1 <- function(Y_qc, gc_qc, K){
  normObj_result <- normalize(Y_qc, gc_qc, K)
  Yhat <- normObj_result$Yhat
  AIC <- normObj_result$AIC
  BIC <- normObj_result$BIC
  RSS <- normObj_result$RSS
  K <- normObj_result$K
  return(list(Yhat=Yhat, AIC=AIC, BIC=BIC, RSS=RSS, K=K))
}

#' Function Dexcription
#'
#' Function description.
#' @param Y_qc
#' @param gc_qc
#' @param K
#' @param normal_index
#' @keywords 
#' @export
#' @examples
#' coverageObj1
normObj2 <- function(Y_qc, gc_qc, K, normal_index){
  normObj_result <- normalize2(Y_qc, gc_qc, K, normal_index)
  Yhat <- normObj_result$Yhat
  AIC <- normObj_result$AIC
  BIC <- normObj_result$BIC
  RSS <- normObj_result$RSS
  K <- normObj_result$K
  return(list(Yhat=Yhat, AIC=AIC, BIC=BIC, RSS=RSS, K=K))
}

#' Function Dexcription
#'
#' Function description.
#' @param Y_qc
#' @param Yhat
#' @param optK
#' @param K
#' @param sampname_qc
#' @keywords 
#' @export
#' @examples
#' coverageObj1
segment1 <- function(Y_qc, Yhat, optK, K, sampname_qc,
                     ref_qc, chr, lmax, mode){
  finalcall <- segment(Y_qc, Yhat, optK, K, sampname_qc,
                         ref_qc, chr, lmax, mode)
  return(list(finalcall=finalcall))
}

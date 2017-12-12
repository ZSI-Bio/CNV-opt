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
  Y <- matrix(data=as.integer(0), nrow = nrow(targets_for_chr), ncol = 0)
  for(sample in sampname) {
    cov_targets_for_sample <- cov_table[cov_table[,"sample_name"] == sample,]
    cov_targets_for_sample <- cov_targets_for_sample[with(cov_targets_for_sample, order(target_id)), ]
    Y <- cbind(Y, cov_targets_for_sample[,"read_count"])
  }
  colnames(Y) <- sampname
  rownames(Y) <- targets_for_chr[,"target_id"]
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

unify_calls_format <- function(finalcall){
  colnames(finalcall)[colnames(finalcall) == 'lratio'] <- 'codex_lratio'
  colnames(finalcall)[colnames(finalcall) == 'mBIC'] <- 'codex_mBIC'
  return(list(finalcall=finalcall))
}

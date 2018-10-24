library(CODEX)

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

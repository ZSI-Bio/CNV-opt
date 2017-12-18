#' Function Dexcription
#'
#' Function description.
#' @param cov_file
#' @keywords 
#' @export
#' @examples
#' run_CODEXCOV
run_CODEXCOV <- function(K_from,
                         K_to,
                         lmax,
                         reference_set_select_method,
                         num_of_samples_in_reference_set,
                         cov_table){
  
  sampname <- unique(cov_table[,"sample_name"])
  sampname <- as.character(sampname)
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

    ###################################################
    ### code chunk number 5: gcmapp1
    ###################################################
    gcmapp1_result <- gcmapp1(chr, ref)
    gc <- gcmapp1_result$gc

    ###################################################
    ### code chunk number 7: normObj1
    ###################################################
    normObj_result <- normObj1(Y, gc, K = K_from:K_to)
    Yhat <- normObj_result$Yhat
    AIC <- normObj_result$AIC
    BIC <- normObj_result$BIC
    RSS <- normObj_result$RSS
    K <- normObj_result$K
    
    ###################################################
    ### code chunk number 8: normObj2 (eval = FALSE)
    ###################################################
    ## normObj_result <- normObj2(Y, gc, K = 1:9, normal_index=seq(1,45,2))
    ## Yhat <- normObj_result$Yhat
    ## AIC <- normObj_result$AIC
    ## BIC <- normObj_result$BIC
    ## RSS <- normObj_result$RSS
    ## K <- normObj_result$K
    
    ###################################################
    ### code chunk number 9: choiceofK (eval = FALSE)
    ###################################################
    #choiceofK(AIC, BIC, RSS, K, filename = paste("choiceofK_", chr, ".pdf", sep = ""))
    
    ###################################################
    ### code chunk number 10: fig1
    ###################################################
    #plot(K, RSS, type = "b", xlab = "Number of latent variables")
    #plot(K, AIC, type = "b", xlab = "Number of latent variables")
    #plot(K, BIC, type = "b", xlab = "Number of latent variables")
    
    ###################################################
    ### code chunk number 11: segment1
    ###################################################
    finalcallIt <- segment1(Y, Yhat, K[which.max(BIC)], K, sampname,
                            ref, chr, lmax, mode = "integer")$finalcall
    if (nrow(finalcall)==0){finalcall <- matrix(nrow=0, ncol=ncol(finalcallIt))} 
    finalcall <- rbind(finalcall, finalcallIt)
  
  }
  finalcall <- unify_calls_format(finalcall)$finalcall
  finalcall
}

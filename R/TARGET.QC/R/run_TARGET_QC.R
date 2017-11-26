run_TARGET_QC <- function(mapp_thresh,
                          cov_thresh_from,
                          cov_thresh_to,
                          length_thresh_from,
                          length_thresh_to,
                          gc_thresh_from,
                          gc_thresh_to,
                          K_from,
                          K_to,
                          lmax,
                          cov_table){
  
  sampname <- unique(cov_table[,"sample_name"])
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
    mapp <- gcmapp1_result$mapp

    ###################################################
    ### code chunk number 6: qcObj1
    ###################################################
    qcObj1_result <- qcObj1(Y, sampname, chr, ref, mapp, gc, cov_thresh = c(cov_thresh_from, cov_thresh_to), 
                        length_thresh = c(length_thresh_from, length_thresh_to), mapp_thresh, 
                        gc_thresh = c(gc_thresh_from, gc_thresh_to))
    Y_qc <- qcObj1_result$Y_qc
    sampname_qc <- qcObj1_result$sampname_qc
    gc_qc <- qcObj1_result$gc_qc
    ref_qc <- qcObj1_result$ref_qc

    ###################################################
    ### code chunk number 7: normObj1
    ###################################################
    normObj_result <- normObj1(Y_qc, gc_qc, K = K_from:K_to)
    Yhat <- normObj_result$Yhat
    AIC <- normObj_result$AIC
    BIC <- normObj_result$BIC
    RSS <- normObj_result$RSS
    K <- normObj_result$K
    
    ###################################################
    ### code chunk number 8: normObj2 (eval = FALSE)
    ###################################################
    ## normObj_result <- normObj2(Y_qc, gc_qc, K = 1:9, normal_index=seq(1,45,2))
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
    finalcallIt <- segment1(Y_qc, Yhat, K[which.max(BIC)], K, sampname_qc,
                            ref_qc, chr, lmax, mode = "integer")$finalcall
    if (nrow(finalcall)==0){finalcall <- matrix(nrow=0, ncol=ncol(finalcallIt))} 
    finalcall <- rbind(finalcall, finalcallIt)
  
  }
  finalcall <- unify_calls_format(finalcall)$finalcall
  finalcall
}

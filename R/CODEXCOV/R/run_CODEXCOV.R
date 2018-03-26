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
                         input_cov_table,
                         reference_sample_set_file,
                         output_calls_file){

  con <- file(reference_sample_set_file, open='r')
  reference_sample_set <- readLines(con)
  cov_table <- read.csv(input_cov_table)
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

    for (i in 1:length(reference_sample_set)) {
      if (reference_sample_set[[i]] == '') {
        next()
      }
      samples <- unlist(strsplit(reference_sample_set[[i]], ','))
      actual_sample <- samples[1]
      reference_samples <- samples[-1]
      samples <- samples[order(samples[,1]),]
      Y_subset <- Y[,samples]

      ###################################################
      ### code chunk number 7: normObj1
      ###################################################
      normObj_result <- normObj1(Y_subset, gc, K = K_from:K_to)
      Yhat <- normObj_result$Yhat
      AIC <- normObj_result$AIC
      BIC <- normObj_result$BIC
      RSS <- normObj_result$RSS
      K <- normObj_result$K

      ###################################################
      ### code chunk number 11: segment1
      ###################################################
      finalcallIt <- segment1(Y_subset, Yhat, K[which.max(BIC)], K, samples,
                              ref, chr, lmax, mode = "integer")$finalcall
      finalcallIt <- finalcallIt[finalcallIt[,"sample_name"] == actual_sample,]
      if (nrow(finalcall)==0){finalcall <- matrix(nrow=0, ncol=ncol(finalcallIt))}
      finalcall <- rbind(finalcall, finalcallIt)
      print(finalcall)
    }
  }
  finalcall <- unify_calls_format(finalcall)$finalcall
  write.csv(finalcall, output_calls_file, row.names=F)
}

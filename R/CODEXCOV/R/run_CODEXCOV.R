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
                         input_bed,
                         reference_sample_set_file,
                         output_calls_file){

  con <- file(reference_sample_set_file, open='r')
  reference_sample_set <- readLines(con)
  Y <- read.csv(input_cov_table)
  sampname <- colnames(Y)
  targets <- read.delim(input_bed)
  rownames(Y) <- 1:nrow(Y)
  rownames(targets) <- 1:nrow(targets)
  
  finalcall <- matrix(nrow=0, ncol=13)
  ref <- IRanges(start = targets[,"st_bp"], end = targets[,"ed_bp"])

  ###################################################
  ### code chunk number 5: gcmapp1
  ###################################################
  gcmapp1_result <- gcmapp1(targets[1,'chr'], ref)
  gc <- gcmapp1_result$gc

  for (i in 1:length(reference_sample_set)) {
    if (reference_sample_set[[i]] == '') {
      next()
    }
    samples <- unlist(strsplit(reference_sample_set[[i]], ','))
    actual_sample <- samples[1]
    reference_samples <- samples[-1]
    samples <- sort(samples)
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
                            ref, targets[1,'chr'], lmax, mode = "integer")$finalcall
    finalcallIt <- finalcallIt[finalcallIt[,"sample_name"] == actual_sample,]
    if (nrow(finalcall)==0){finalcall <- matrix(nrow=0, ncol=ncol(finalcallIt))}
    finalcall <- rbind(finalcall, finalcallIt)
    print(finalcall)
  }
  finalcall <- unify_calls_format(finalcall)$finalcall
  write.csv(finalcall, output_calls_file, row.names=F)
}

#' Function Description
#'
#' Function description.
#' @param calls
#' @param refs
#' @keywords 
#' @export
#' @examples
#' run_CNVCALLER.EVALUATOR
run_CNVCALLER.EVALUATOR <- function(calls,
                                    refs,
                                    parameters){

  TP <- 0
  FP <- 0
  TN <- 0
  FN <- 0
  num_of_original_samples_in_refs <- length(unique(refs[,"sample_name"]))
  chromosomes <- c(1:22, "X", "Y", paste0("chr",c(1:22, "X", "Y")))
  for(chromosome in chromosomes) {
    print(paste("Processing chr: ", chromosome, sep=""))
    calls_for_chr <- subset(calls, chr == chromosome)
    refs_for_chr <- subset(refs, chr == chromosome)
    if (nrow(calls_for_chr) == 0 && nrow(refs_for_chr) == 0) {  # TODO
      next()
    }
    intersection_matrix <- build_intersection_matrix(calls_for_chr, refs_for_chr)
    intersection_matrix <- filter_intersection_matrix_by_overlap_factor(intersection_matrix, parameters$min_overlap_factor)
    targets <- refs_for_chr[,c("chr", "st_bp", "ed_bp")]
    num_of_original_targets_in_refs <- nrow(targets[!duplicated(targets[,c("chr", "st_bp", "ed_bp")]),])
    confusion_matrix <- calc_confusion_matrix(intersection_matrix, num_of_original_targets_in_refs, num_of_original_samples_in_refs)
    TP <- TP + confusion_matrix$TP
    FP <- FP + confusion_matrix$FP
    TN <- TN + confusion_matrix$TN
    FN <- FN + confusion_matrix$FN
  }
  quality_statistics <- calc_quality_statistics(TP, FP, TN, FN)
  return(list(TP=TP,
              FP=FP,
              TN=TN,
              FN=FN,
              sensitivity=round(quality_statistics$sensitivity, digits=3), 
              specificity=round(quality_statistics$specificity, digits=3), 
              precision=round(quality_statistics$precision, digits=3), 
              accuracy=round(quality_statistics$accuracy, digits=3)))
}


#######################################################################
####################### calls or refs matrix ##########################
#######################################################################
# "sample_name","chr","cnv","st_bp","ed_bp","copy_no"
# NA0123         1   del   10000   20000   1

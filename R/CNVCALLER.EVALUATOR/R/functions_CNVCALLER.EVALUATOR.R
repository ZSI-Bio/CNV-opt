
build_intersection_matrix <- function(calls, refs){
  intersection_matrix <- matrix(data=as.integer(0), nrow = nrow(calls), ncol = nrow(refs))
  if (nrow(intersection_matrix) > 0 && ncol(intersection_matrix) > 0) {
    for (i in 1:nrow(intersection_matrix)) {
      for (j in 1:ncol(intersection_matrix)) {
        if (as.character(calls[i,"sample_name"]) == as.character(refs[j,"sample_name"]) && 
            as.character(calls[i,"chr"]) == as.character(refs[j,"chr"]) && 
            as.character(calls[i,"cnv"]) == as.character(refs[j,"cnv"])) {
          overlap_length <- calc_overlap_length(calls[i,"st_bp"], 
                                                calls[i,"ed_bp"], 
                                                refs[j,"st_bp"], 
                                                refs[j,"ed_bp"])
          call_length <- strtoi(calls[i,"ed_bp"]) - strtoi(calls[i,"st_bp"])
          ref_length <- strtoi(refs[j,"ed_bp"]) - strtoi(refs[j,"st_bp"])
          overlap_factor <- overlap_length / ((call_length + ref_length) / 2) * 100
          intersection_matrix[i,j] <- round(overlap_factor, 2)
        }
      }
    }
  }
  intersection_matrix
}

filter_intersection_matrix_by_overlap_factor <- function(intersection_matrix, min_overlap_factor){
  if (nrow(intersection_matrix) > 0 && ncol(intersection_matrix) > 0) {
    for (i in 1:nrow(intersection_matrix)) {
      for (j in 1:ncol(intersection_matrix)) {
        if (intersection_matrix[i,j] < min_overlap_factor) {
          intersection_matrix[i,j] <- 0.00
        }
      }
    }
  }
  intersection_matrix
}

calc_number_of_different_copy_number_for_cnv <- function(cnv, calls){
  copy_no <- c()
  for (i in 1:nrow(calls)) {
    if (as.character(calls[i,"chr"]) == as.character(cnv[1,"chr"]) &&
        calls[i,"st_bp"] == cnv[1,"st_bp"] &&
        calls[i,"ed_bp"] == cnv[1,"ed_bp"] &&
        !is.na(calls[i,"copy_no"])) {
      copy_no <- c(copy_no, calls[i,"copy_no"])
    }
  }
  length(unique(copy_no))
}

calc_NA_rate_for_cnv <- function(cnv, calls){
  num_of_samples <- length(unique(calls[,"sample_name"]))
  num_of_NA <- 0
  for (i in 1:nrow(calls)) {
    if (as.character(calls[i,"chr"]) == as.character(cnv[1,"chr"]) &&
        calls[i,"st_bp"] == cnv[1,"st_bp"] &&
        calls[i,"ed_bp"] == cnv[1,"ed_bp"] &&
        is.na(calls[i,"cnv"])) {
      num_of_NA <- num_of_NA + 1
    }
  }
  round(num_of_NA / num_of_samples, 2)
}

calc_cnv_frequency <- function(cnv, calls){
  num_of_samples <- length(unique(calls[,"sample_name"]))
  num_of_same_cnv <- 0
  for (i in 1:nrow(calls)) {
    if (as.character(calls[i,"chr"]) == as.character(cnv[1,"chr"]) &&
        calls[i,"st_bp"] == cnv[1,"st_bp"] &&
        calls[i,"ed_bp"] == cnv[1,"ed_bp"] &&
        as.character(calls[i,"cnv"]) == as.character(cnv[1,"cnv"])) {
      num_of_same_cnv <- num_of_same_cnv + 1
    }
  }
  round(num_of_same_cnv / num_of_samples, 2)
}

calc_overlap_length <- function(min1, max1, min2, max2){
  overlap_length <- max(0, min(strtoi(max1), strtoi(max2)) - max(strtoi(min1), strtoi(min2)))
  overlap_length
}

calc_quality_statistics <- function(TP, FP, TN, FN){
  sensitivity <- if (TP + FN > 0) TP / (TP + FN) else 0
  specificity <- if (TN + FP > 0) TN / (TN + FP) else 0
  precision <- if (TP + FP > 0) TP / (TP + FP) else 0
  accuracy <- if (TP + TN + FP + FN > 0) (TP + TN) / (TP + TN + FP + FN) else 0
  return(list(sensitivity=round(sensitivity, digits=3), 
              specificity=round(specificity, digits=3), 
              precision=round(precision, digits=3), 
              accuracy=round(accuracy, digits=3)))
}

calc_confusion_matrix <- function(intersection_matrix, num_of_original_targets_in_refs, num_of_original_samples_in_refs){
  # TP
  TP <- 0
  if (nrow(intersection_matrix) > 0) {
    for (i in 1:nrow(intersection_matrix)) {
      if (sum(intersection_matrix[i,] != 0) != 0) {
        TP <- TP + 1
      }
    }
  }
  # FP
  FP <- nrow(intersection_matrix) - TP
  # FN
  FN <- 0
  if (ncol(intersection_matrix) > 0) {
    for (j in 1:ncol(intersection_matrix)) {
      if (sum(intersection_matrix[,j] != 0) == 0) {
        FN <- FN + 1
      }
    }
  }
  # TN
  TN <- (num_of_original_targets_in_refs * num_of_original_samples_in_refs) - FN
  return(list(TP=TP, FP=FP, TN=TN, FN=FN))
}


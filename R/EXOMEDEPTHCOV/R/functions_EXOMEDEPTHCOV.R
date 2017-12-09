library(ExomeDepth)

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



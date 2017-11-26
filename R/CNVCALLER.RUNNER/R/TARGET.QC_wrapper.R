library('TARGET.QC')

run_wrapper_TARGET.QC <- function(mapp_thresh,
                                  cov_thresh_from,
                                  cov_thresh_to,
                                  length_thresh_from,
                                  length_thresh_to,
                                  gc_thresh_from,
                                  gc_thresh_to,
                                  cov_table){
  cov_table <- run_TARGET.QC(as.double(mapp_thresh),
                             strtoi(cov_thresh_from),
                             strtoi(cov_thresh_to),
                             strtoi(length_thresh_from),
                             strtoi(length_thresh_to),
                             strtoi(gc_thresh_from),
                             strtoi(gc_thresh_to),
                             cov_table
  )
  cov_table
}

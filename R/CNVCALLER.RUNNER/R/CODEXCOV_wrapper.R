library('CODEXCOV')

#' Function Description
#'
#' Function description.
#' @param mapp_thresh
#' @param cov_thresh_from
#' @param cov_thresh_to
#' @param length_thresh_from
#' @param length_thresh_to
#' @param gc_thresh_from
#' @param gc_thresh_to
#' @param K_from
#' @param K_to
#' @param ds
#' @param lmax
#' @keywords 
#' @export
#' @examples
#' run_wrapper_CODEXCOV
run_wrapper_CODEXCOV <- function(mapp_thresh,
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
  calls <- run_CODEXCOV(as.double(mapp_thresh),
                        strtoi(cov_thresh_from),
                        strtoi(cov_thresh_to),
                        strtoi(length_thresh_from),
                        strtoi(length_thresh_to),
                        strtoi(gc_thresh_from),
                        strtoi(gc_thresh_to),
                        strtoi(K_from),
                        strtoi(K_to),
                        strtoi(lmax),
                        cov_table
  )
  calls
}

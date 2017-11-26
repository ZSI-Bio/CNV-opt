library('CODEXCOV')

#' Function Description
#'
#' Function description.
#' @param K_from
#' @param K_to
#' @param lmax
#' @param cov_table
#' @keywords 
#' @export
#' @examples
#' run_wrapper_CODEXCOV
run_wrapper_CODEXCOV <- function(K_from,
                                 K_to,
                                 lmax,
                                 cov_table){
  calls <- run_CODEXCOV(strtoi(K_from),
                        strtoi(K_to),
                        strtoi(lmax),
                        cov_table
  )
  calls
}

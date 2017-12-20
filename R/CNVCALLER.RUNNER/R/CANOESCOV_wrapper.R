library('CANOESCOV')

run_wrapper_CANOESCOV <- function(cov_table){
  calls <- run_CANOESCOV('canoes',
                         0,
                         cov_table)
  calls
}

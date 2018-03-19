library('CANOESCOV')

run_wrapper_CANOESCOV <- function(reference_set_select_method,
                                  num_of_samples_in_reference_set,
                                  cov_table){
  calls <- run_CANOESCOV(reference_set_select_method,
                         strtoi(num_of_samples_in_reference_set),
                         cov_table)
  calls
}

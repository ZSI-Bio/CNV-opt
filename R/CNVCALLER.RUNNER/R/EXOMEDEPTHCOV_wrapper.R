library('EXOMEDEPTHCOV')

run_wrapper_EXOMEDEPTHCOV <- function(reference_set_select_method,
                                      num_of_samples_in_reference_set,
                                      cov_table){
  calls <- run_EXOMEDEPTHCOV(reference_set_select_method,
                             num_of_samples_in_reference_set,
                             cov_table)
  calls
}

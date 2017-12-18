library('CODEXCOV')

run_wrapper_CODEXCOV <- function(K_from,
                                 K_to,
                                 lmax,
                                 reference_set_select_method,
                                 num_of_samples_in_reference_set,
                                 cov_table){
  calls <- run_CODEXCOV(strtoi(K_from),
                        strtoi(K_to),
                        strtoi(lmax),
                        reference_set_select_method,
                        strtoi(num_of_samples_in_reference_set),
                        cov_table)
  calls
}

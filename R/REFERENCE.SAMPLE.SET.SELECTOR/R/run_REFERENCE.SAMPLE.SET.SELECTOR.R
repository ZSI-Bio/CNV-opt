run_REFERENCE.SAMPLE.SET.SELECTOR <- function(investigated_sample,
                                              Y,
                                              select_method,
                                              num_refs,
                                              target_length){
  if(select_method == "canoes") {
    reference_samples <- canoes_method(investigated_sample, Y, num_refs)$reference_samples
  } else if(select_method == "codex") {
    #reference_samples <- codex_method(investigated_sample, Y, num_refs)$reference_samples
  } else if(select_method == "exomedepth") {
    reference_samples <- exomedepth_method(investigated_sample, Y, num_refs, target_length)$reference_samples
  } else if(select_method == "clamms") {
    #reference_samples <- clamms_method(investigated_sample, Y, num_refs)$reference_samples
  }
  reference_samples
}

run_REFERENCE.SAMPLE.SET.SELECTOR <- function(sample,
                                              cov_table,
                                              select_method,
                                              num_refs){
  sampname <- unique(cov_table[,"sample_name"])
  targets <- cov_table[,c("target_id", "chr", "pos_min", "pos_max")]
  targets <- targets[!duplicated(targets[,"target_id"]),]
  targets <- targets[with(targets, order(target_id)), ]
  Y <- coverageObj1(cov_table, sampname, targets)$Y
  if(select_method == "canoes") {
    reference_samples <- canoes_method(investigated_sample, Y, num_refs)$reference_samples
  } else if(select_method == "codex") {
    #reference_samples <- codex_method(investigated_sample, Y, num_refs)$reference_samples
  } else if(select_method == "exomedepth") {
    #reference_samples <- exomedepth_method(investigated_sample, Y, num_refs)$reference_samples
  } else if(select_method == "clamms") {
    #reference_samples <- clamms_method(investigated_sample, Y, num_refs)$reference_samples
  }
  reference_samples
}

# cov_table format:
#  sample_name target_id chr  pos_min  pos_max read_count
#1     NA19012    193524   Y 25426932 25427053          0
#2     NA19012    193525   Y 25431556 25431676          0
#3     NA19012    193526   Y 25535089 25535239          0
#4     NA19012    193527   Y 25537286 25537526          0
#5     NA19012    193528   Y 25538793 25538913          0

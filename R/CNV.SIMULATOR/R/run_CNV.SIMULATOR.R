run_CNV.SIMULATOR <- function(input_cov_table,
                              input_bed,
                              input_males,
                              input_females,
                              output_cov_table,
                              output_generated_cnvs,
                              number_of_cnvs_per_sample,
                              min_number_of_regions,
                              max_number_of_regions,
                              simulation_mode){


  Y <- read.csv(input_cov_table)
  sampname <- colnames(Y)
  targets <- read.delim(input_bed)
  males <- as.character(unlist(read.table(input_males, sep = ",")))
  females <- as.character(unlist(read.table(input_females, sep = ",")))
  generated_cnvs <- matrix(nrow=0, ncol=4)
  colnames(generated_cnvs) <- c('sample','chr','st_bp','ed_bp')
  if (simulation_mode == "downsample") {
    downsample_factor <- 0.5
    for (sample in sampname) {
      print(paste("Generating arficial CNVs in sample: ", sample, sep=""))
      for (i in 1:number_of_cnvs_per_sample) {
        cnv_length <- floor(runif(1, min=min_number_of_regions, max=max_number_of_regions))
        cnv_start <- floor(runif(1, min=1, max=nrow(targets)))
        for (j in cnv_start:(min(cnv_start+cnv_length-1,nrow(targets)))) {
          Y[j,sample] <- floor(Y[j,sample]*downsample_factor)
        }
        print(paste(sample, targets[cnv_start,1], targets[cnv_start,2], targets[cnv_start+cnv_length,3], sep=" "))
        generated_cnvs <- rbind(generated_cnvs, matrix(c(sample, targets[cnv_start,1], targets[cnv_start,2], targets[cnv_start+cnv_length,3]), nrow = 1))
      }
    }
  } else if (simulation_mode == "replace") {
    Y_males <- Y[,males]
    Y_females <- Y[,females]
    for (female in females) {
      print(paste("Generating arficial CNVs in sample: ", female, sep=""))
      male <- males[floor(runif(1, min=1, max=length(males)))]
      for (i in 1:number_of_cnvs_per_sample) {
        cnv_length <- floor(runif(1, min=min_number_of_regions, max=max_number_of_regions))
        cnv_start <- floor(runif(1, min=1, max=nrow(targets)))
        for (j in cnv_start:(min(cnv_start+cnv_length-1,nrow(targets)))) {
          Y_females[j,female] <- Y_males[j,male]
          Y[j,female] <- Y[j,male]
        }
        print(paste(female, targets[cnv_start,1], targets[cnv_start,2], targets[cnv_start+cnv_length,3], sep=" "))
        generated_cnvs <- rbind(generated_cnvs, matrix(c(female, targets[cnv_start,1], targets[cnv_start,2], targets[cnv_start+cnv_length,3]), nrow = 1))
      }
    }
    write.csv(Y_males, paste(output_cov_table, ".males", sep=""), row.names=F, quote=F)
    write.csv(Y_females, paste(output_cov_table, ".females", sep=""), row.names=F, quote=F)
  } else {
    print("Choose proper simulation mode!!!")
  }
  write.csv(Y, output_cov_table, row.names=F, quote=F)
  write.csv(generated_cnvs, output_generated_cnvs, row.names=F, quote=F)
}

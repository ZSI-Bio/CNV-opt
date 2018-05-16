library(methods)
library(exomeCopy)

run_EXOMECOPYCOV <- function(input_cov_table,
                             input_bed,
                             reference_sample_set_file,
                             output_calls_file){

  con <- file(reference_sample_set_file, open='r')
  reference_sample_set <- readLines(con)
  Y <- read.csv(input_cov_table)
  targets <- read.delim(input_bed)
  rownames(Y) <- 1:nrow(Y)
  rownames(targets) <- 1:nrow(targets)
  chr <- targets[1,'chr']
  ref <- IRanges(start = targets[,"st_bp"], end = targets[,"ed_bp"])
  if (length(ref) == 0) {    # 0 elements for specified chromosome in bed
    next()
  }
  target <- GRanges(seqname = chr, IRanges(start = start(ref) + 1, end = end(ref)))
  gc <- getgc(chr, ref)

  rdata_org <- RangedData(IRanges(start=start(ref), end=end(ref)), space=rep(chr,nrow(Y)), universe="hg19", gc=gc, gc.sq=gc^2) 
  finalcall <- matrix(nrow=0, ncol=13)

  for (i in 1:length(reference_sample_set)) {
    if (reference_sample_set[[i]] == '') {
      next()
    }
    samples <- unlist(strsplit(reference_sample_set[[i]], ','))
    actual_sample <- samples[1]
    reference_samples <- samples[-1]
    samples <- sort(samples)
    rdata <- rdata_org

    for(sample.name in samples) {
      rdata[[sample.name]] <- Y[,sample.name]
    }

    rdata[["bg"]] <- generateBackground(samples, rdata, median)
    rdata[["log.bg"]] <- log(rdata$bg + .1) 
    rdata[["width"]] <- width(ref)

    samples <- c(actual_sample)
    fit.list <- lapply(samples, function(sample.name) {
      lapply(seqlevels(target), function(seq.name) {
        print(paste("Processing sample: ", sample.name, sep=""))
        exomeCopy(rdata, sample.name, X.names = c("log.bg", "gc", "gc.sq", "width"), S = 0:4, d = 2)
      })
    })
    compiled.segments <- compileCopyCountSegments(fit.list)
    finalcallIt <- unify_calls_format(compiled.segments, chr)$calls
    if (nrow(finalcall)==0){finalcall <- matrix(nrow=0, ncol=ncol(finalcallIt))}
    finalcall <- rbind(finalcall, finalcallIt)
    print(finalcallIt)

  }
  write.csv(finalcall, output_calls_file, row.names=F)
}

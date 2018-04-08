
# from CODEX package
getgc <- function(chr, ref) {
  library(GenomeInfoDb)
  library(BSgenome.Hsapiens.UCSC.hg19)
  if (chr == "X" | chr == "x" | chr == "chrX" | chr == "chrx") {
    chrtemp <- 23
  } else if (chr == "Y" | chr == "y" | chr == "chrY" | chr == "chry") {
    chrtemp <- 24
  } else {
    chrtemp <- as.numeric(mapSeqlevels(as.character(chr), "NCBI")[1])
  }
  if (length(chrtemp) == 0) 
    message("Chromosome cannot be found in NCBI Homo sapiens database!")
  chrm <- unmasked(Hsapiens[[chrtemp]])
  seqs <- Views(chrm, ref)
  af <- alphabetFrequency(seqs, baseOnly = TRUE, as.prob = TRUE)
  gc <- round((af[, "G"] + af[, "C"]) * 100,2)
  gc
}

unify_calls_format <- function(compiled.segments, chr){
  calls <- matrix(nrow=length(compiled.segments$sample.name), ncol=7)
  colnames(calls) <- c('sample_name', 'chr', 'st_bp', 'ed_bp', 'cnv', 'copy_no', 'log_odds')
  calls[,'sample_name'] <- compiled.segments$sample.name
  calls[,'chr'] <- rep(chr, nrow(calls))
  calls[,'st_bp'] <- unlist(start(ranges(compiled.segments)))
  calls[,'ed_bp'] <- unlist(end(ranges(compiled.segments)))
  calls[,'copy_no'] <- compiled.segments$copy.count
  calls[,'cnv'] <- ifelse(calls[,'copy_no'] > 2, 'dup', 'del')
  calls[,'log_odds'] <- compiled.segments$log.odds
  calls <- subset(calls, calls[,'copy_no'] != "2")
  return(list(calls=calls))
}

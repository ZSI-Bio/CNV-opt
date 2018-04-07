library(methods)
library(exomeCopy)

run_EXOMECOPYCOV <- function(input_cov_table,
                             input_bed,
                             reference_sample_set_file,
                             output_calls_file){

  con <- file(reference_sample_set_file, open='r')
  reference_sample_set <- readLines(con)
  Y <- read.csv(input_cov_table)
  sample.names <- colnames(Y)
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

  rdata <- RangedData(IRanges(start=start(ref), end=end(ref)), space=rep(chr,nrow(Y)), universe="hg19", gc=gc, gc.sq=gc^2)  

  for(sample.name in sample.names) {
    rdata[[sample.name]] <- Y[,sample.name]
  }

  rdata[["bg"]] <- width(ref) # generateBackground(sample.names, rdata, median)
  rdata[["log.bg"]] <- log(rdata$bg + .1) 
  rdata[["width"]] <- width(ref)

  fit.list <- lapply(sample.names, function(sample.name) {
    lapply(seqlevels(target), function(seq.name) {
      print(paste("Processing sample: ", sample.name, sep=""))
      exomeCopy(rdata, sample.name, X.names = c("log.bg", "gc", "gc.sq", "width"), S = 0:4, d = 2)
    })
  })
  compiled.segments <- compileCopyCountSegments(fit.list)
  print(compiled.segments)















  #calls <- data.frame(matrix(nrow=0, ncol=13))
  #chr <- targets[1,'chr']
  #ref <- IRanges(start = targets[,"st_bp"], end = targets[,"ed_bp"])
  #if (length(ref) == 0) {    # 0 elements for specified chromosome in bed
  #  next()
  #}
  #Y <- cbind(rep(chr, nrow(Y)), start(ref), end(ref), Y)
  #target_length <- c()
  #for (i in 1:nrow(Y)) {
  #  target_length <- c(target_length, width(ref[i]))
  #}

  # TODO better transformation
  #write.table(Y, file=paste('cov_', chr, '.tsv', sep=""), quote=FALSE, sep="\t", col.names = F, row.names = F)
  #canoes.reads <- read.table(paste('cov_', chr, '.tsv', sep=""))

  #gc <- getgc(chr, ref)
  #target <- seq(1, nrow(Y))
  #canoes.reads <- cbind(target, gc, canoes.reads)
  #sampname <- as.vector(sampname)
  #names(canoes.reads) <- c("target", "gc", "chromosome", "start", "end", sampname)
  #colnames(canoes.reads) <- c("target", "gc", "chromosome", "start", "end", sampname)
  #write.table(as.data.frame(canoes.reads),file="canoes.reads.csv", quote=F, sep=",",row.names=T,col.names=T)
  #xcnv.list <- vector('list', length(sampname))
  #for (i in 1:length(reference_sample_set)) {
  #  if (reference_sample_set[[i]] == '') {
  #    next()
  #  }
  #  samples <- unlist(strsplit(reference_sample_set[[i]], ','))
  #  actual_sample <- samples[1]
  #  reference_samples <- samples[-1]
  #  xcnv.list[[i]] <- CANOESCOV::CallCNVs(sample.name=actual_sample,
  #                                        reference.samples=reference_samples,
  #                                        counts=canoes.reads)
  #}
  #xcnvs <- do.call('rbind', xcnv.list)
  #if (nrow(calls)==0){calls <- matrix(nrow=0, ncol=ncol(xcnvs))} 
  #calls <- rbind(calls, xcnvs)

  # unify results format
  #if (nrow(calls) != 0) {
  #  calls[colnames(calls) == 'CNV'] <- as.character(unlist(calls[colnames(calls) == 'CNV']))
  #  calls[calls == 'DEL'] <- 'del'
  #  calls[calls == 'DUP'] <- 'dup'
  #}
  #colnames(calls)[colnames(calls) == 'SAMPLE'] <- 'sample_name'
  #targets <- as.vector(calls[colnames(calls) == 'TARGETS'])
  #targets <- as.character(unlist(targets))
  #splitted_targets <- do.call(rbind, strsplit(targets, '..', fixed = TRUE))
  #calls <- cbind(calls, splitted_targets)
  #colnames(calls)[colnames(calls) == '1'] <- 'st_exon'
  #colnames(calls)[colnames(calls) == '2'] <- 'ed_exon'
  #intervals <- as.vector(calls[colnames(calls) == 'INTERVAL'])
  #intervals <- as.character(unlist(intervals))
  #splitted_intervals <- do.call(rbind, strsplit(intervals, c(':'), fixed = TRUE))
  #intervals <- as.vector(splitted_intervals[,2])
  #intervals <- as.character(unlist(intervals))
  #splitted_intervals <- do.call(rbind, strsplit(intervals, c('-'), fixed = TRUE))
  #calls <- cbind(calls, splitted_intervals)
  #colnames(calls)[colnames(calls) == '1'] <- 'st_bp'
  #colnames(calls)[colnames(calls) == '2'] <- 'ed_bp'
  #colnames(calls)[colnames(calls) == 'CNV'] <- 'cnv'
  #calls <- calls[,-which(names(calls) %in% c('KB', 'MID_BP', 'NUM_TARG', 'Q_SOME', 'TARGETS', 'INTERVAL'))]
  #colnames(calls)[colnames(calls) == 'CHR'] <- 'chr'
  #colnames(calls)[colnames(calls) == 'MLCN'] <- 'copy_no'
  #calls[colnames(calls) == 'sample_name'] <- as.character(unlist(calls[colnames(calls) == 'sample_name']))
  #calls[colnames(calls) == 'st_bp'] <- as.character(unlist(calls[colnames(calls) == 'st_bp']))
  #calls[colnames(calls) == 'ed_bp'] <- as.character(unlist(calls[colnames(calls) == 'ed_bp']))
  #calls[colnames(calls) == 'st_exon'] <- as.character(unlist(calls[colnames(calls) == 'st_exon']))
  #calls[colnames(calls) == 'ed_exon'] <- as.character(unlist(calls[colnames(calls) == 'ed_exon']))
  #write.csv(calls, output_calls_file, row.names=F)
}

#   SAMPLE CNV             INTERVAL     KB CHR   MID_BP    TARGETS NUM_TARG MLCN Q_SOME
#1      S2 DEL 22:25713988-25756059 42.071  22 25735024 1132..1137        6    1 99
#2      S3 DEL 22:24373138-24384231 11.093  22 24378684   936..942        7    0 77



library(methods)
library(CODEX)

run_CANOESCOV <- function(reference_set_select_method,
                          num_of_samples_in_reference_set,
                          cov_table){

  sampname <- unique(cov_table[,"sample_name"])
  targets <- cov_table[,c("target_id", "chr", "pos_min", "pos_max")]
  targets <- targets[!duplicated(targets[,"target_id"]),]
  targets <- targets[with(targets, order(target_id)), ]
  
  calls <- data.frame(matrix(nrow=0, ncol=13))
  chrs <- c(1:22, "X", "Y", paste0("chr",c(1:22, "X", "Y")))
  for(chr in chrs) {
    targets_for_chr <- targets[targets[,"chr"] == chr,]
    ref <- IRanges(start = targets_for_chr[,"pos_min"], end = targets_for_chr[,"pos_max"])
    if (length(ref) == 0) {    # 0 elements for specified chromosome in bed
      next()
    }
    Y <- coverageObj1(cov_table, sampname, targets_for_chr, chr)$Y
    Y <- cbind(rep(chr, nrow(Y)), start(ref), end(ref), Y)
    target_length <- c()
    for (i in 1:nrow(Y)) {
      target_length <- c(target_length, width(ref[i]))
    }

    # TODO better transformation
    write.table(Y, file=paste('cov_', chr, '.tsv', sep=""), quote=FALSE, sep="\t", col.names = F, row.names = F)
    canoes.reads <- read.table(paste('cov_', chr, '.tsv', sep=""))

    gc <- getgc(chr, ref)
    target <- seq(1, nrow(Y))
    canoes.reads <- cbind(target, gc, canoes.reads)
    sampname <- as.vector(sampname)
    names(canoes.reads) <- c("target", "gc", "chromosome", "start", "end", sampname)
    colnames(canoes.reads) <- c("target", "gc", "chromosome", "start", "end", sampname)
    write.table(as.data.frame(canoes.reads),file="canoes.reads.csv", quote=F, sep=",",row.names=T,col.names=T)
    xcnv.list <- vector('list', length(sampname))
    for (i in 1:length(sampname)){
      xcnv.list[[i]] <- CANOESCOV::CallCNVs(sample.name=sampname[i],
                                            counts=canoes.reads,
                                            reference_set_select_method=reference_set_select_method,
                                            num_of_samples_in_reference_set=num_of_samples_in_reference_set,
                                            target_length=target_length)
    }
    xcnvs <- do.call('rbind', xcnv.list)
    if (nrow(calls)==0){calls <- matrix(nrow=0, ncol=ncol(xcnvs))} 
    calls <- rbind(calls, xcnvs)
  }

  # unify results format
  if (nrow(calls) != 0) {
    calls[colnames(calls) == 'CNV'] <- as.character(unlist(calls[colnames(calls) == 'CNV']))
    calls[calls == 'DEL'] <- 'del'
    calls[calls == 'DUP'] <- 'dup'
  }
  colnames(calls)[colnames(calls) == 'SAMPLE'] <- 'sample_name'
  targets <- as.vector(calls[colnames(calls) == 'TARGETS'])
  targets <- as.character(unlist(targets))
  splitted_targets <- do.call(rbind, strsplit(targets, '..', fixed = TRUE))
  calls <- cbind(calls, splitted_targets)
  colnames(calls)[colnames(calls) == '1'] <- 'st_exon'
  colnames(calls)[colnames(calls) == '2'] <- 'ed_exon'
  intervals <- as.vector(calls[colnames(calls) == 'INTERVAL'])
  intervals <- as.character(unlist(intervals))
  splitted_intervals <- do.call(rbind, strsplit(intervals, c(':'), fixed = TRUE))
  intervals <- as.vector(splitted_intervals[,2])
  intervals <- as.character(unlist(intervals))
  splitted_intervals <- do.call(rbind, strsplit(intervals, c('-'), fixed = TRUE))
  calls <- cbind(calls, splitted_intervals)
  colnames(calls)[colnames(calls) == '1'] <- 'st_bp'
  colnames(calls)[colnames(calls) == '2'] <- 'ed_bp'
  colnames(calls)[colnames(calls) == 'CNV'] <- 'cnv'
  calls <- calls[,-which(names(calls) %in% c('KB', 'MID_BP', 'NUM_TARG', 'Q_SOME', 'TARGETS', 'INTERVAL'))]
  colnames(calls)[colnames(calls) == 'CHR'] <- 'chr'
  colnames(calls)[colnames(calls) == 'MLCN'] <- 'copy_no'
  calls[colnames(calls) == 'sample_name'] <- as.character(unlist(calls[colnames(calls) == 'sample_name']))
  calls[colnames(calls) == 'st_bp'] <- as.character(unlist(calls[colnames(calls) == 'st_bp']))
  calls[colnames(calls) == 'ed_bp'] <- as.character(unlist(calls[colnames(calls) == 'ed_bp']))
  calls[colnames(calls) == 'st_exon'] <- as.character(unlist(calls[colnames(calls) == 'st_exon']))
  calls[colnames(calls) == 'ed_exon'] <- as.character(unlist(calls[colnames(calls) == 'ed_exon']))
  calls
}

#   SAMPLE CNV             INTERVAL     KB CHR   MID_BP    TARGETS NUM_TARG MLCN Q_SOME
#1      S2 DEL 22:25713988-25756059 42.071  22 25735024 1132..1137        6    1 99
#2      S3 DEL 22:24373138-24384231 11.093  22 24378684   936..942        7    0 77



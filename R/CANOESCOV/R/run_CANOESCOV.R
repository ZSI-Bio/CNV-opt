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

    write.table(Y, file=paste('cov_', chr, '.tsv', sep=""), quote=FALSE, sep="\t", col.names = F, row.names = F)
    canoes.reads <- read.table(paste('cov_', chr, '.tsv', sep=""))

    # read in the data
    gc <- getgc(chr, ref)
    #canoes.reads <- Y #read.table(paste('cov_', chr, '.tsv', sep=""))
    names(canoes.reads) <- c("chromosome", "start", "end", sampname)
    colnames(canoes.reads) <- c("chromosome", "start", "end", sampname)
    target <- seq(1, nrow(Y))
    canoes.reads <- cbind(target, gc, canoes.reads)
    names(canoes.reads) <- c("target", "gc", "chromosome", "start", "end", sampname)
    colnames(canoes.reads) <- c("target", "gc", "chromosome", "start", "end", sampname)
    write.table(as.data.frame(canoes.reads),file="canoes.reads.csv", quote=F, sep=",",row.names=T,col.names=T)
    xcnv.list <- vector('list', length(sampname))
    print(canoes.reads$chromosome)
    for (i in 1:length(sampname)){
      xcnv.list[[i]] <- CallCNVs(sampname[i], canoes.reads)
    }
    xcnvs <- do.call('rbind', xcnv.list)
    xcnvs
  }

  # unify names of output columns
  # DEL -> del
  # DUP -> dup
  # generate copy_no
  if (nrow(calls) != 0) {
    calls[calls == 'DEL'] <- 'del'
    calls[calls == 'DUP'] <- 'dup'
    calls[,1] <- as.character(calls[,1])
    colnames(calls)[1] <- 'sample_name'
  }
  colnames(calls)[colnames(calls) == 'SAMPLE'] <- 'sample_name'
  colnames(calls)[colnames(calls) == 'start.p'] <- 'st_exon'
  colnames(calls)[colnames(calls) == 'end.p'] <- 'ed_exon'
  colnames(calls)[colnames(calls) == 'type'] <- 'cnv'
  calls <- calls[,-which(names(calls) %in% c('nexons', 'id'))]
  colnames(calls)[colnames(calls) == 'start'] <- 'st_bp'
  colnames(calls)[colnames(calls) == 'end'] <- 'ed_bp'
  colnames(calls)[colnames(calls) == 'chromosome'] <- 'chr'
  colnames(calls)[colnames(calls) == 'BF'] <- 'exomedepth_BF'
  colnames(calls)[colnames(calls) == 'reads.expected'] <- 'norm_cov'
  colnames(calls)[colnames(calls) == 'reads.observed'] <- 'raw_cov'
  colnames(calls)[colnames(calls) == 'MLCN'] <- 'copy_no'
  calls
}

#   SAMPLE CNV             INTERVAL     KB CHR   MID_BP    TARGETS NUM_TARG MLCN Q_SOME
#1      S2 DEL 22:25713988-25756059 42.071  22 25735024 1132..1137        6    1 99
#2      S3 DEL 22:24373138-24384231 11.093  22 24378684   936..942        7    0 77



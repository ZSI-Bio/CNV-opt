Test <- function(){
  # read in the data
  gc <- read.table("gc.txt")$V2
  canoes.reads <- read.table("canoes.reads.txt")
  # rename the columns of canoes.reads
  sample.names <- paste("S", seq(1:26), sep="")
  names(canoes.reads) <- c("chromosome", "start", "end", sample.names)
  # create a vector of consecutive target ids
  target <- seq(1, nrow(canoes.reads))
  # combine the data into one data frame
  canoes.reads <- cbind(target, gc, canoes.reads)
  # call CNVs in each sample
  # create a vector to hold the results for each sample
  xcnv.list <- vector('list', length(sample.names))
  for (i in 1:length(sample.names)){
    xcnv.list[[i]] <- CallCNVs(sample.names[i], canoes.reads) 
  }
  # combine the results into one data frame
  xcnvs <- do.call('rbind', xcnv.list)
  # inspect the first two CNV calls
  print(head(xcnvs, 2))
  # plot all the CNV calls to a pdf
  pdf("CNVplots.pdf")
  for (i in 1:nrow(xcnvs)){
     PlotCNV(canoes.reads, xcnvs[i, "SAMPLE"], xcnvs[i, "TARGETS"])
  }
  dev.off()
  # genotype all the CNVs calls made above in sample S2
  genotyping.S2 <- GenotypeCNVs(xcnvs, "S2", canoes.reads)
  # inspect the genotype scores for the first two CNV calls
  print(head(genotyping.S2, 2))
}

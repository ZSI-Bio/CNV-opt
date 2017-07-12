count_coverage_for_single_sample_by_CODEX <- function(bambedObj, mapqthres) {
    ref <- bambedObj$ref
    chr <- bambedObj$chr
    bamdir <- bambedObj$bamdir
    st <- start(ref)[1]
    ed <- end(ref)[length(ref)]
    Y <- matrix(NA, nrow = length(ref), ncol = 1)
    readlength <- rep(NA, 1)
    i <- 1
    bamurl <- bamdir[i]
    which <- RangesList(quack = IRanges(st - 10000, ed + 10000))
    names(which) <- as.character(chr)
    what <- c("pos", "mapq", "qwidth")
    flag <- scanBamFlag(isDuplicate = FALSE, isUnmappedQuery = FALSE,
                        isNotPassingQualityControls = FALSE, 
                        isFirstMateRead = TRUE)
    param <- ScanBamParam(which = which, what = what, flag = flag)
    bam <- scanBam(bamurl, param = param)[[1]]
    mapqfilter <- (bam[["mapq"]] >= mapqthres)
    readlength[i] <- round(mean(bam[["qwidth"]]))
    if(is.nan(readlength[i])){
      flag <- scanBamFlag(isDuplicate = FALSE, isUnmappedQuery = FALSE,
                          isNotPassingQualityControls = FALSE)
      param <- ScanBamParam(which = which, what = what, flag = flag)
      bam <- scanBam(bamurl, param = param)[[1]]
      mapqfilter <- (bam[["mapq"]] >= mapqthres)
      readlength[i] <- round(mean(bam[["qwidth"]]))
    }
    message("Getting coverage for sample ", bamurl, ": ", 
            "read length ", readlength[i], ".", sep = "")
    irang <- IRanges(bam[["pos"]][mapqfilter], width = 
                    bam[["qwidth"]][mapqfilter])
    Y[, i] <- countOverlaps(ref, irang)
    list(Y = Y, readlength = readlength)
}

library(CODEX)
args = commandArgs(trailingOnly=TRUE)
if (length(args) != 5) {
  stop("Invalid number of arguments!!!", call.=FALSE)
}
bamFile <- args[1] # "/home/wiktor/CNV/applications/CODEX/CODEX/data/20/NA12830.chrom20.ILLUMINA.bwa.CEU.exome.20121211.bam"
bedFile <- args[2] # "/home/wiktor/CNV/applications/CODEX/CODEX/data/20/chr22_400_to_500.bed"
mapqthres <- strtoi(args[3]) # 20
chr <- args[4] # 20
outputFile <- args[5] # /home/wiktor/CNV/coverage/NA12830_coverage.txt

#library("WES.1KG.WUGSC")
#dirPath <- system.file("extdata", package = "WES.1KG.WUGSC")
#bamFile <- list.files(dirPath, pattern = '*.bam$')
#bamdir <- file.path(dirPath, bamFile)
#bedFile <- file.path(dirPath, "chr22_400_to_500.bed")
#sampname <- file.path(dirPath, "sampname")
#bamFile <-  bamdir[1]
#chr <- "22"
#mapqthres <- 20

bambedObj <- getbambed(bamdir = bamFile, bedFile = bedFile, sampname = NULL, projectname = NULL, chr)
coverageObj <- count_coverage_for_single_sample_by_CODEX(bambedObj, mapqthres = mapqthres)
finalDf <- data.frame(chrom=chr, start=start(bambedObj$ref), end=end(bambedObj$ref), readCount=coverageObj$Y )
write.table(finalDf, sep="\t", col.names=F, row.names=F, quote="",  file = outputFile)





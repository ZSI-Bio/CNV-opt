source("https://bioconductor.org/biocLite.R")
biocLite("WES.1KG.WUGSC")
library("WES.1KG.WUGSC")
dirPath <- system.file("extdata", package = "WES.1KG.WUGSC")
bamFile <- list.files(dirPath, pattern = '*.bam$')
bamdir <- file.path(dirPath, bamFile)
bedFile <- file.path(dirPath, "chr22_400_to_500.bed")

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop("Invalid number of arguments!!!", call.=FALSE)
}
if(args[1] == "bedFile"){bedFile}
else if (args[1] == "dirPath"){dirPath}
else if (agrs[1] == "sampName"){sampname}


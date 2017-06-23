### R code from vignette source 'CODEX_vignettes.Rnw'
### Encoding: UTF-8

###################################################
### code chunk number 1: install1 (eval = FALSE)
###################################################
## ## try http:// if https:// URLs are not supported
source("http://bioconductor.org/biocLite.R")
biocLite("CODEX")


###################################################
### code chunk number 2: install2 (eval = FALSE)
###################################################
## install.packages("devtools")
## library(devtools)
## install_github("yuchaojiang/CODEX/package")


###################################################
### code chunk number 3: bambedObj1
###################################################
#mapp_thresh <- 0.9
#cov_thresh_from <- 20
#cov_thresh_to <- 4000
#length_thresh_from <- 20
#length_thresh_to <- 2000
#gc_thresh_from <- 20
#gc_thresh_to <- 80
#K_from <- 1
#K_to <- 2
#lmax <- 200  # Maximum CNV length in number of exons returned.
#cov_file <- file.path("/home/wiktor/CNV-opt/data/EXAMPLE_BAMS/coverage.tsv")
#sampname <- as.matrix(read.table("/home/wiktor/CNV-opt/data/EXAMPLE_BAMS/sampname"))
#bedFile <- file.path("/home/wiktor/CNV-opt/data/EXAMPLE_BAMS/EXOME.bed")

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 13) {
  stop("Invalid number of arguments!!!", call.=FALSE)
}
mapp_thresh <- as.double(args[1])
cov_thresh_from <- strtoi(args[2])
cov_thresh_to <- strtoi(args[3])
length_thresh_from <- strtoi(args[4])
length_thresh_to <- strtoi(args[5])
gc_thresh_from <- strtoi(args[6])
gc_thresh_to <- strtoi(args[7])
K_from <- strtoi(args[8])
K_to <- strtoi(args[9])
lmax <- strtoi(args[10])  # Maximum CNV length in number of exons returned.
cov_file <- file.path(args[11])
sampname <- as.matrix(read.table(args[12]))
bedFile <- file.path(args[13])

library(CODEX)
finalcall <- matrix(nrow=0,ncol=14)
chrs <- c(1:22, "X", "Y", paste0("chr",c(1:22, "X", "Y")))
          
for(chr in chrs) {
  exomtarg <- read.table(bedFile, sep = '\t')
  exomtarg <- exomtarg[exomtarg[,1] == chr,]
  ref <- IRanges(start = exomtarg[,2], end = exomtarg[,3])
  if (length(ref) == 0) {    # 0 elements for specified chromosome in bed file
    next()
  }
  
  
  ###################################################
  ### code chunk number 4: coverageObj1
  ###################################################
  #coverageObj <- getcoverage(bambedObj, mapqthres = 20)
  #Y <- coverageObj$Y; 
  #readlength <- coverageObj$readlength
  #write.table(Y, file = "data", sep = " ", col.names = F, row.names = F)
  
  Y <- scan(cov_file)
  Y <- matrix(Y, ncol = length(sampname), byrow = TRUE)
  # [TODO] dodac filtr wartosci (wierszy) dla odpowiedniego chromosomu !!!
  
  ###################################################
  ### code chunk number 5: gcmapp1
  ###################################################
  gc <- getgc(chr, ref)
  mapp <- getmapp(chr, ref)
  
  
  ###################################################
  ### code chunk number 6: qcObj1
  ###################################################
  qcObj <- qc(Y, sampname, chr, ref, mapp, gc, cov_thresh = c(cov_thresh_from, cov_thresh_to), 
              length_thresh = c(length_thresh_from, length_thresh_to), mapp_thresh = mapp_thresh, 
              gc_thresh = c(gc_thresh_from, gc_thresh_to))
  Y_qc <- qcObj$Y_qc; sampname_qc <- qcObj$sampname_qc; gc_qc <- qcObj$gc_qc
  mapp_qc <- qcObj$mapp_qc; ref_qc <- qcObj$ref_qc; qcmat <- qcObj$qcmat
  #write.table(qcmat, file = paste(chr, '_qcmat', '.txt', sep=''),
  #            sep='\t', quote=FALSE, row.names=FALSE)
  
  ###################################################
  ### code chunk number 7: normObj1
  ###################################################
  normObj <- normalize(Y_qc, gc_qc, K = K_from:K_to)
  Yhat <- normObj$Yhat; AIC <- normObj$AIC; BIC <- normObj$BIC
  RSS <- normObj$RSS; K <- normObj$K
  
  ###################################################
  ### code chunk number 8: normObj2 (eval = FALSE)
  ###################################################
  ## normObj <- normalize2(Y_qc, gc_qc, K = 1:9, normal_index=seq(1,45,2))
  ## Yhat <- normObj$Yhat; AIC <- normObj$AIC; BIC <- normObj$BIC
  ## RSS <- normObj$RSS; K <- normObj$K
  
  
  ###################################################
  ### code chunk number 9: choiceofK (eval = FALSE)
  ###################################################
  ## choiceofK(AIC, BIC, RSS, K, filename = paste(projectname, "_", chr, 
  ##     "_choiceofK", ".pdf", sep = ""))
  
  
  ###################################################
  ### code chunk number 10: fig1
  ###################################################
  #filename <- paste(projectname, "_", chr, "_choiceofK", ".pdf", sep = "")
  #Kmax <- length(AIC)
  #par(mfrow = c(1, 3))
  #plot(K, RSS, type = "b", xlab = "Number of latent variables")
  #plot(K, AIC, type = "b", xlab = "Number of latent variables")
  #plot(K, BIC, type = "b", xlab = "Number of latent variables")
  
  
  ###################################################
  ### code chunk number 11: segment1
  ###################################################
  optK = K[which.max(BIC)]
  finalcallIt <- matrix(nrow=0,ncol=14)
  finalcallIt <- segment(Y_qc, Yhat, optK = optK, K = K, sampname_qc,
                         ref_qc, chr, lmax = lmax, mode = "integer")
  finalcall <- rbind(finalcall, finalcallIt)
  
  
  ###################################################
  ### code chunk number 12: segment2 (eval = FALSE)
  ###################################################
  ## write.table(finalcall, file = paste(projectname, '_', chr, '_', optK,
  ##             '_CODEX_frac.txt', sep=''), sep='\t', quote=FALSE, row.names=FALSE)
  ## save.image(file = paste(projectname, '_', chr, '_image', '.rda', sep=''),
  ##      compress='xz')
}
finalcall
